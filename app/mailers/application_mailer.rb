class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM_ADDRESS", "nucampusmarketplace@gmail.com")
  layout "mailer"
end
