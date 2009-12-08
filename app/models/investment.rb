class Investment < ActiveRecord::Base
  validates_presence_of :xml

  def self.find_all
    find(:all, :order => "updated_at")
  end

  protected

  def validate
    # add validation here
  end
end
