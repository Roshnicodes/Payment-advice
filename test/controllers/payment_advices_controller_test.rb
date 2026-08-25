require "test_helper"

class PaymentAdvicesControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to login" do
    get payment_advice_url

    assert_redirected_to login_url
  end

  test "shows payment advice generator after login" do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }

    assert_redirected_to payment_advice_url
    follow_redirect!

    assert_response :success
    assert_select "h1", "Payment Advice Studio"
    assert_select "h2", "Payment Advice"
    assert_select "#bank-master"
  end

  test "shows login at root" do
    get root_url

    assert_response :success
    assert_select "h1", "Payment Advice"
    assert_select ".login-card"
  end

  test "creates payment advice record" do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }

    assert_difference("PaymentAdviceRecord.count", 1) do
      post payment_advices_url, params: { payment_advice: payment_advice_params }, as: :json
    end

    assert_response :created
    assert_equal "PA-TEST-001", response.parsed_body["advice_no"]
    assert_equal "900.0", response.parsed_body["net_amount"]
  end

  test "destroys payment advice record" do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }
    payment_advice = PaymentAdviceRecord.create!(payment_advice_params)

    assert_difference("PaymentAdviceRecord.count", -1) do
      delete payment_advice_record_url(payment_advice), as: :json
    end

    assert_response :no_content
  end

  test "updates existing payment advice when advice number matches" do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }
    PaymentAdviceRecord.create!(payment_advice_params)

    assert_no_difference("PaymentAdviceRecord.count") do
      post payment_advices_url,
        params: { payment_advice: payment_advice_params.merge(payee_name: "Updated Vendor") },
        as: :json
    end

    assert_response :success
    assert_equal "Updated Vendor", PaymentAdviceRecord.find_by!(advice_no: "PA-TEST-001").payee_name
  end

  test "sends payment advice email to recipient" do
    post login_url, params: { email: "accounts@example.com", password: "demo1234" }
    payment_advice = PaymentAdviceRecord.create!(payment_advice_params)

    assert_emails 1 do
      post send_mail_payment_advice_path(payment_advice), as: :json
    end

    assert_response :success
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "vendor@example.com" ], mail.to
    assert_equal "Payment Advice PA-TEST-001", mail.subject
  end

  private

  def payment_advice_params
    {
      company_name: "Test Company",
      advice_no: "PA-TEST-001",
      payee_name: "Demo Vendor",
      payee_email: "vendor@example.com",
      invoice_no: "INV-TEST-001",
      invoice_date: Date.current,
      gross_amount: 1000,
      tds_amount: 100,
      other_deduction: 0,
      payment_mode: "NEFT",
      reference_no: "UTR123",
      bank_name: "HDFC Bank",
      payment_date: Date.current,
      remarks: "Test payment"
    }
  end
end
