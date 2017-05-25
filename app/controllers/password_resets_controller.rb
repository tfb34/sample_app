class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit,:update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] #case 1

  def new
  end

  def create
  	@user = User.find_by(email: params[:password_reset][:email].downcase)
  	if @user
  		#create token, digest-token, time-sent, send email
  		@user.create_reset_digest #include this method in User model
  		@user.send_password_reset_email#should include token
  		flash[:info] = "Email sent with password reset instructions"
  		redirect_to root_url
  	else
  		flash.now[:danger] = "Email address not found"
  		render 'new'
  	end
  end
#handle request to change password
  def edit
  end

  def update
  	if params[:user][:password].empty? #case (3)
  		@user.errors.add(:password, "can't be empty")
  		render 'edit'
  	elsif @user.update_attributes(user_params) #case(4), user_params method below
  		log_in @user
  		flash[:success] = "Password has been reset."
  		redirect_to @user 
  	else
  		render 'edit'   #case(2)
  	end
  		
  end

  private 

  def get_user
  	@user = User.find_by(email: params[:email])# email is in url 
  end

  #confirms a valid user.
  def valid_user
  	unless(@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
  		redirect_to root_url
  	end
  end

  def user_params
  	params.require(:user).permit(:password, :password_confirmation)
  end


  #checks expiration of reset token.
  def check_expiration
  	if @user.password_reset_expired?
  		flash[:danger] = "Password reset has expired."
  		redirect_to new_password_reset_url
  	end
  end
end
