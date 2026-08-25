require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "logs in with valid demo credentials" do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }

    assert_redirected_to payment_advice_url
  end

  test "rejects invalid login" do
    post login_url, params: { email: "accounts", password: "123" }

    assert_response :unprocessable_entity
    assert_select ".login-card"
  end
end
