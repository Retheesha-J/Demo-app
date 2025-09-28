require "rails_helper"

RSpec.describe "Passwords", type: :request do
    let!(:user){create(:user, password: "oldpassword")}

    describe "POST /users/password (forgot password)" do
        it "sends the password instructions" do
            expect{
                post user_password_path,params:{ user:{email:user.email}}
        }.to change{ ActionMailer::Base.deliveries.count}.by(1)

            expect(response).to redirect_to(new_user_session_path)
            follow_redirect!

            expect(response.body).to include("You will receive an email")
        end

        it "does not send instructions for invalid email" do
            expect{
                post user_password_path,params:{ user:{ email:"wrong@example.com"}}
                }.not_to change{ActionMailer::Base.deliveries.count}
            expect(response.body).to include("not found")
        end
    end

    describe "PUT /users/password(reset password)" do
        it "reset the password with a valid token" do
            token=user.send_reset_password_instructions

            put user_password_path, params: {
                user:{
                    reset_password_token: token,
                    password:"newpassword",
                    password_confirmation:"newpassword"
                }
            }

            expect(response).to redirect_to(dashboard_path)
            follow_redirect!
            expect(response.body).to include("Your password has been changed successfully")
        end
    end
end