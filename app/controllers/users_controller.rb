class UsersController < ApplicationController
 before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
 before_action :correct_user, only:[:edit, :update]
 before_action :admin_user, only: :destroy

  def index
    #@users = User.all
    #@users = User.paginate(page: params[:page])
    #show only users that are activated
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  	#debugger
  end
#we need to send an email with an activation link 
  def create
  	@user = User.new(user_params)
  	if @user.save
     # UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      #flash[:success] = "Welcome to the Sample App!" #local
      flash[:info] = "Please check your email to activate your account."
      #redirect_to @user
      #we now require account activation so we redirect to the root url
      redirect_to root_url
  	else
  		render 'new'
  	end
  end

 def edit
  #@user = User.find(params[:id])
  #the above line is executed in the 'before_action'
 end

  def update
    #@user = User.find(params[:id])
    #the above line is executed in the 'before_action'
    if @user.update_attributes(user_params)
      #handle a succesful update.
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private
  #ensuring user submits data for the following 4 attributes, no more no less
	  def user_params
	  	params.require(:user).permit(:name,:email,:password,:password_confirmation)
	  end

    #confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    #confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
