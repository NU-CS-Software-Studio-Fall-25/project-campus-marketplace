class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM_ADDRESS", "t8753486@gmail.com")
  layout "mailer"
end
