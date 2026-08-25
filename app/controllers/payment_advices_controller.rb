class PaymentAdvicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payment_advice, only: %i[destroy send_mail]

  def new
    Bank.ensure_default!
    @banks = Bank.ordered.map { |bank| { id: bank.id, name: bank.name } }
    @payment_advices = PaymentAdviceRecord.recent.limit(50).map { |advice| payment_advice_payload(advice) }
    @next_advice_no = PaymentAdviceRecord.next_advice_no
  end

  def create
    payment_advice = PaymentAdviceRecord.find_or_initialize_by(advice_no: payment_advice_params[:advice_no])
    payment_advice.assign_attributes(payment_advice_params)

    if payment_advice.save
      render json: payment_advice_payload(payment_advice), status: payment_advice.previously_new_record? ? :created : :ok
    else
      render json: { errors: payment_advice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @payment_advice.destroy

    head :no_content
  end

  def send_mail
    if @payment_advice.payee_email.blank?
      render json: { error: "Recipient Email is required before sending mail." }, status: :unprocessable_entity
      return
    end

    unless mail_delivery_configured?
      render json: { error: "SMTP is not configured. Add sender email settings first." }, status: :unprocessable_entity
      return
    end

    configure_local_mail_delivery! if local_mail_delivery?
    PaymentAdviceMailer.with(payment_advice: @payment_advice).payment_advice.deliver_now
    render json: { message: mail_success_message }
  rescue StandardError => e
    render json: { error: "Email could not be sent: #{e.message}" }, status: :bad_gateway
  end

  private

  def set_payment_advice
    @payment_advice = PaymentAdviceRecord.find(params[:id])
  end

  def mail_delivery_configured?
    Rails.env.development? || Rails.env.test? || ENV.values_at("SMTP_ADDRESS", "SMTP_PASSWORD").all?(&:present?)
  end

  def local_mail_delivery?
    Rails.env.development? && ENV["SMTP_ADDRESS"].blank?
  end

  def configure_local_mail_delivery!
    ActionMailer::Base.delivery_method = :file
    ActionMailer::Base.file_settings = { location: Rails.root.join("tmp", "sent_mails").to_s }
  end

  def mail_success_message
    if local_mail_delivery?
      "Local test email created for #{@payment_advice.payee_email}. Check tmp/sent_mails."
    else
      "Payment advice sent to #{@payment_advice.payee_email}."
    end
  end

  def payment_advice_params
    params.expect(payment_advice: [
      :company_name, :advice_no, :payee_name, :payee_email, :invoice_no, :invoice_date,
      :gross_amount, :tds_amount, :other_deduction, :payment_mode, :reference_no,
      :bank_name, :payment_date, :remarks
    ])
  end

  def payment_advice_payload(advice)
    {
      id: advice.id,
      company_name: advice.company_name,
      advice_no: advice.advice_no,
      payee_name: advice.payee_name,
      payee_email: advice.payee_email,
      invoice_no: advice.invoice_no,
      invoice_date: advice.invoice_date,
      gross_amount: advice.gross_amount.to_s,
      tds_amount: advice.tds_amount.to_s,
      other_deduction: advice.other_deduction.to_s,
      net_amount: advice.net_amount.to_s,
      payment_mode: advice.payment_mode,
      reference_no: advice.reference_no,
      bank_name: advice.bank_name,
      payment_date: advice.payment_date,
      remarks: advice.remarks,
      created_at: advice.created_at.strftime("%d %b %Y")
    }
  end
end
