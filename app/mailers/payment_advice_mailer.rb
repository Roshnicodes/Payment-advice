class PaymentAdviceMailer < ApplicationMailer
  def payment_advice
    @payment_advice = params[:payment_advice]

    mail(
      to: @payment_advice.payee_email,
      subject: "Payment Advice #{@payment_advice.advice_no}"
    )
  end
end
