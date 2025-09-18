class UsersController < ApplicationController
    def signup
        @user=User.new
    end
    skip_before_action :verify_authenticity_token, only: [:create, :login,:destroy,:update]
    def create
        @user=User.new(user_params)
        if @user.save
            redirect_to login_path,notice: "User created Successfully"
        else
            render json:{error:@user.errors.full_messages},status: :unprocessable_entity
        end
    end

    def getusers
        @users=User.all
        render json: @users
    end
    
    def login
        @user=User.new
    end
      
    def login_create
        user=User.find_by(email:params[:user][:email])
        if user&&user.password==params[:user][:password]
            redirect_to dashboard_path, notice: "Welcome, #{user.name}!"
        else
            flash[:alert] = "Invalid email or password"
            redirect_to login_path
        end
    end

    def dashboard
        @users=User.all
    end

    def destroy
        user=User.find(params[:id])
        if user.destroy
            redirect_to dashboard_path,notice: "User deleted Successfully"
        else
            redirect_to dashboard_path,alert:"Failed to delete the user"
        end
    end

    def edit 
        @user=User.find(params[:id])
    end

    def update
        user=User.find(params[:id])
        if user.update(user_params)
            render json: {message:"updated successfully",user:user}
        else
            render json: {error:user.errors.full_messages}
        end
    end

    private
    def user_params
        params.require(:user).permit(:name,:email,:password)
    end
end
