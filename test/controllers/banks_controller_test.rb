require "test_helper"

class BanksControllerTest < ActionDispatch::IntegrationTest
  setup do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }
  end

  test "creates a bank" do
    assert_difference("Bank.count", 1) do
      post banks_url, params: { bank: { name: "Canara Bank" } }, as: :json
    end

    assert_response :created
    assert_equal "Canara Bank", response.parsed_body["name"]
  end

  test "destroys a bank" do
    bank = Bank.create!(name: "Union Bank of India")

    assert_difference("Bank.count", -1) do
      delete bank_url(bank), as: :json
    end

    assert_response :no_content
  end
end
