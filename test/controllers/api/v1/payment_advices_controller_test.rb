require "test_helper"

module Api
  module V1
    class PaymentAdvicesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @old_api_token = ENV.delete("PAYMENT_ADVICE_API_TOKEN")
      end

      teardown do
        ENV["PAYMENT_ADVICE_API_TOKEN"] = @old_api_token
      end

      test "creates payment advice and sends email" do
        assert_difference("PaymentAdviceRecord.count", 1) do
          assert_emails 1 do
            post api_v1_payment_advices_send_mail_url,
              params: { payment_advice: payment_advice_params },
              as: :json
          end
        end

        assert_response :created
        assert_equal "Payment advice sent to vendor@example.com.", response.parsed_body["message"]
        assert_equal "PA-API-001", response.parsed_body.dig("payment_advice", "advice_no")
        assert_equal "vendor@example.com", response.parsed_body.dig("payment_advice", "recipient_email")
        assert_equal "900.0", response.parsed_body.dig("payment_advice", "net_amount")
        assert_equal [ "vendor@example.com" ], ActionMailer::Base.deliveries.last.to
      end

      test "accepts recipient email alias" do
        payload = payment_advice_params.except(:payee_email).merge(recipient_email: "recipient@example.com")

        assert_emails 1 do
          post api_v1_payment_advices_send_mail_url,
            params: { payment_advice: payload },
            as: :json
        end

        assert_response :created
        assert_equal "recipient@example.com", PaymentAdviceRecord.find_by!(advice_no: "PA-API-001").payee_email
        assert_equal "recipient@example.com", response.parsed_body.dig("payment_advice", "recipient_email")
        assert_equal [ "recipient@example.com" ], ActionMailer::Base.deliveries.last.to
      end

      test "updates existing payment advice and sends email" do
        PaymentAdviceRecord.create!(payment_advice_params)

        assert_no_difference("PaymentAdviceRecord.count") do
          assert_emails 1 do
            post api_v1_payment_advices_send_mail_url,
              params: { payment_advice: payment_advice_params.merge(payee_name: "Updated Vendor") },
              as: :json
          end
        end

        assert_response :success
        assert_equal "Updated Vendor", PaymentAdviceRecord.find_by!(advice_no: "PA-API-001").payee_name
      end

      test "requires bearer token when api token is configured" do
        ENV["PAYMENT_ADVICE_API_TOKEN"] = "secret-token"

        post api_v1_payment_advices_send_mail_url,
          params: { payment_advice: payment_advice_params },
          as: :json

        assert_response :unauthorized
        assert_equal "Invalid API token.", response.parsed_body["error"]
      end

      test "accepts valid bearer token when api token is configured" do
        ENV["PAYMENT_ADVICE_API_TOKEN"] = "secret-token"

        assert_emails 1 do
          post api_v1_payment_advices_send_mail_url,
            params: { payment_advice: payment_advice_params },
            headers: { "Authorization" => "Bearer secret-token" },
            as: :json
        end

        assert_response :created
      end

      private

      def payment_advice_params
        {
          company_name: "Test Company",
          advice_no: "PA-API-001",
          payee_name: "Demo Vendor",
          payee_email: "vendor@example.com",
          invoice_no: "INV-API-001",
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
  end
end
