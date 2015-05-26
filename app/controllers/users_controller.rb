class UsersController < ApplicationController
  def index
  	redirect_to action: "new"
  end

  def new
  	@user = User.new
  end

  def create
 	@user = User.new(params_user)
 	@user.valid?
 	if simple_captcha_valid?
	  	if @user.save
	  		flash[:notice] = "User successfully added!"
	  		redirect_to root_url
	  	else
	  		flash[:error] = "data not valid"
	        render 'new'
	  	end
	else
        flash[:errors] = "Please re-enter the recaptcha code below!" 
        render 'new'
  	end
  	# render :text => params_user
  end

  def edit
  end

  private 
  	def params_user
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :captcha, :captcha_key)
	end
end
