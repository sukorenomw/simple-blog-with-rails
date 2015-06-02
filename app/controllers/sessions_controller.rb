class SessionsController < ApplicationController
	def new

	end

	def create
		username = params[:username]
		password = params[:password]

		user = User.authenticate(username, password)
		if user
			session[:user] = user.id
			flash[:notice] = "welcome, #{user.username}"
			redirect_to root_url
		else
			flash[:error] = "Invalid email or password"
			render "new"
		end
	end

	def destroy
        session[:user] = nil
        flash[:notice] = "logout session success"
        redirect_to root_url
    end
end
