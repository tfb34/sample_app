class ApplicationMailer < ActionMailer::Base
  #default from: 'from@example.com'
  default from: 'noreply@example.com'
  layout 'mailer'
end
