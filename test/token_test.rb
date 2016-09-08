require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  test 'truth' do
    assert_kind_of Module, Cenit::Token
  end
end
