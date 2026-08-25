class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_FROM", ENV.fetch("SMTP_USERNAME", "notification@ploughmanagro.com"))
  layout "mailer"
end
