class UsersController < ApplicationController
  def index
  	redirect_to action: "new"
  end

  def new
  	@user = User.new
    respond_to do | format |
      format.html
      format.js
    end
  end

  def create
   	@user = User.new(params_user)
   	@user.valid?
    # respond_to do | format |
     	if simple_captcha_valid?
    	  	if @user.save
      	  		flash[:notice] = "User successfully added!"
      	  		render 'success'
    	  	else
              flash[:error] = "data not valid"
              render 'new'
    	  	end
    	else
        flash[:errors] = "Please re-enter the recaptcha code below!" 
        render 'new'
    	end
  end

  def edit
  end

  private 
  	def params_user
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :captcha, :captcha_key)
	end
end
