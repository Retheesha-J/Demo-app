class UserMailer < ApplicationMailer
    default from: 'retheesha2002@outlook.com'

    def welcome_email(user)
        @user = user
        mail(to: @user.email, subject: 'Welcome to MyApp')
    end
end
