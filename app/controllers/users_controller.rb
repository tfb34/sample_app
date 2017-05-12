class UsersController < ApplicationController
  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  	#debugger
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      flash[:success] = "Welcome to the Sample App!" #local
      redirect_to @user
  	else
  		render 'new'
  	end
  end

  private
  #ensuring user submits data for the following 4 attributes, no more no less
	  def user_params
	  	params.require(:user).permit(:name,:email,:password,:password_confirmation)
	  end
end
