require File.dirname(__FILE__) + '/../test_helper'

class InvestmentTest < ActiveSupport::TestCase

  fixtures :investments

  def test_invalid_with_empty_attributes
    investment = Investment.new
    assert !investment.valid?
    assert investment.errors.invalid?(:xml)
  end

  def test_valid_with_non_empty_attributes
    investment = Investment.new
    investment.xml = "test non-empty"
    assert investment.valid?
    assert !investment.errors.invalid?(:xml)
  end
end
