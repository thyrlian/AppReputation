require 'test_helper'

class ExceptionTest < Minitest::Test
  def test_unauthorized_error_initialize_with_account
    account = {'username' => 'root', 'password' => 'xxxx'}
    exception = assert_raises AppReputation::Exception::UnauthorizedError do
      raise(AppReputation::Exception::UnauthorizedError, account)
    end
    assert_equal("Cannot authorize account: #{account}", exception.message)
  end
  
  def test_unauthorized_error_initialize_without_account
    exception = assert_raises AppReputation::Exception::UnauthorizedError do
      raise AppReputation::Exception::UnauthorizedError
    end
    assert_equal('Cannot authorize', exception.message)
  end
end
