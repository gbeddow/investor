require "uri"
require "net/http"
require "net/https"
require "erb"
require 'rubygems'
require 'nokogiri'

$welcomeMsg = ""

class AdminController < ApplicationController

  def index
    @errorMsg = ""
    @online_offline = "offline"

    if (!$sessionID.blank?)
      #logger.debug("#{Time.now} index: $sessionID is NOT blank")
      getAccountData($sessionID)
    else
      logger.debug("#{Time.now} index: $sessionID IS blank")
    end

    @all_investments = Investment.find_all
  end

  def signout
    $sessionID = ""
    @errorMsg = ""
    $welcomeMsg = ""
    redirect_to "/admin"
  end

  def signin
    $sessionID = ""
    @errorMsg = ""

    # GetOxSessionWithSource API
    url = "https://oxbranch.optionsxpress.com/accountservice/account.asmx/GetOxSessionWithSource"
    uri = URI.parse(url)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      data = "sUserName=#{ERB::Util.url_encode(params[:sUserName])}&sPassword=#{ERB::Util.url_encode(params[:sPassword])}&sSource=in2441&sSessionID=}"
      res, data = http.post(uri.path, data)
    rescue Timeout::Error => e
      logger.debug("#{Time.now} GetOxSessionWithSource (signin) timeout!")
    end

    #logger.debug("#{Time.now} Code = #{res.code}")
    #logger.debug("#{Time.now} Message = #{res.message}")
    #res.each {|key, val| logger.debug("#{Time.now} key = #{val}")}
    #logger.debug("#{Time.now} data = #{data}")

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      xml = Nokogiri::XML(data)
      sessionID = xml.xpath('//xmlns:CAppLogin/xmlns:SessionID[1]/text()', 'xmlns' => 'http://oxbranch.optionsxpress.com')
      @errorMsg = xml.xpath('//xmlns:CAppLogin/xmlns:ErrorMsg[1]/text()', 'xmlns' => 'http://oxbranch.optionsxpress.com')

      #logger.debug("#{Time.now} signin: xml = #{xml}")
      #logger.debug("#{Time.now} signin: sessionID = #{sessionID}")
      #logger.debug("#{Time.now} signin: @errorMsg = #{@errorMsg}")

      if (@errorMsg.blank?)
        #logger.debug("#{Time.now} signin: @errorMsg IS blank")
        $sessionID = sessionID
        $welcomeMsg =
          "Welcome " +
          xml.xpath('//xmlns:CAppLogin/xmlns:FirstName/text()', 'xmlns' => 'http://oxbranch.optionsxpress.com').to_s + " " +
          xml.xpath('//xmlns:CAppLogin/xmlns:LastName/text()', 'xmlns' => 'http://oxbranch.optionsxpress.com').to_s + ", " +
          "Account " +
          xml.xpath('//xmlns:CAppLogin/xmlns:AccountNum/text()', 'xmlns' => 'http://oxbranch.optionsxpress.com').to_s
      else
        #logger.debug("#{Time.now} signin: @errorMsg is NOT blank")
      end
    end # case res
    redirect_to "/admin"
  end # def signin

  def getAccountData(sessionID)
    # GetCustPositionsMini API
    url = "https://oxbranch.optionsxpress.com/accountservice/account.asmx/GetCustPositionsMini"
    uri = URI.parse(url)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      data = "sSessionID=#{sessionID}"
      res, data = http.post(uri.path, data)
    rescue Timeout::Error => e
      logger.debug("#{Time.now} GetCustPositionsMini timeout!")
    end

    #logger.debug("#{Time.now} Code = #{res.code}")
    #logger.debug("#{Time.now} Message = #{res.message}")
    #res.each {|key, val| logger.debug("#{Time.now} key = #{val}")}
    #logger.debug("#{Time.now} data = #{data}")

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      xml = Nokogiri::XML(data)
      @errorMsg = xml.xpath('//xmlns:ArrayOfCServPosition/xmlns:CServPosition/xmlns:Message/text()', 'xmlns' => 'http://oxbranch.optionsxpress.com')

      if (!@errorMsg.blank?)
        $welcomeMsg = ""
      else
        @online_offline = "online"
        @all_investments = Investment.find_all
        if @all_investments.length == 0
          investment = Investment.new
          investment.xml = data
          investment.save
        else
          investment = @all_investments[0]
          investment.update_attributes(:xml => data)
          investment.update_attributes(:updated_at => Time.now) # update updated_at even if xml hasn't changed since last update
        end
      end

      #xml = Nokogiri::XML(data)
      #underlyingLast = xml.xpath("//xmlns:ArrayOfCServPosition/xmlns:CServPosition[1]/xmlns:UnderlyingLast[1]/text()", 'xmlns' => 'http://oxbranch.optionsxpress.com')
      #logger.debug("#{Time.now} underlyingLast = #{underlyingLast}")
    else
      logger.debug("#{Time.now} GetCustPositionsMini res=#{res}")
    end

    #logger.debug("#{Time.now} getAccountData: @online_offline = #{@online_offline}")
    if (@online_offline == "online")
      $sessionID = sessionID
    else
      $sessionID = ""
    end
  end # def getAccountData

end # class AdminController
