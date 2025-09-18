class LoginController < ApplicationController

    def login
        user=User.find_by(email:params[:email])

        if user&&user.password==params[:password]
            render json:{message:"Login Successfull",user:user}
            redirect_to dashboard_path, notice: "Welcome, #{user.name}!"
        else
            flash[:alert] = "Invalid email or password"
            redirect_to login_path
        end
    end
end
