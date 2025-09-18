class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy send_email ]
  before_action :require_login, only: [:index, :show]
  skip_before_action :verify_authenticity_token, only: [:login_create]
  # GET /users or /users.json
  def index
    @users = policy_scope(User)
  end

  # GET /users/1 or /users/1.json
  def show
    authorize @user
  end

  # GET /users/new
  def new
    @user = User.new
    authorize @user
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  def dashboard
    @users=User.new
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    authorize @user

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: "#{@user.name} was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        Rails.logger.debug "User save failed: #{@user.errors.full_messages}"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    authorize @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: "#{@user.name} was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  def login
    @user = User.new
  end
  def login_create
    user=User.find_by(email:params[:user][:email])
    if user&&user.authenticate(params[:user][:password]) 
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "#{user.name} successfully logged in!"
    else
      flash[:alert] = "Invalid email or password"
      redirect_to login_path
    end
  end

  def logout
    session[:user_id]=nil
    redirect_to login_path, notice:"You have been logged out"
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    authorize @user
    @user.destroy!


    respond_to do |format|
      format.html { redirect_to users_path, notice: "#{@user.name} was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def send_email
    authorize @user
    user = User.find(params[:id])
    UserMailer.welcome_email(user).deliver_later
    redirect_to users_path, notice: "Email sent to #{user.email}"
  end
  
  def send_bulk_emails
    authorize User
    users=User.where(role: "user")
    users.find_each do |user|
      UserMailer.welcome_email(user).deliver_later
    end
    redirect_to users_path,notice:"#{users.count} emails have been queued"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
    end
    
    def current_user
       @current_user ||= User.find_by(id: session[:user_id])
    end

    def require_login
      unless current_user
        redirect_to login_path, alert: "You must be logged in first."
      end
    end

end
