class CommentsController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update,
:delete]

  def index
  end

  def new

  end

  def edit
  end

  def create
  	respond_to do |format|
		@comment = Comment.new(params_comment)
    @comment.user_id = current_user.id
		if @comment.save
			format.js {@comments = Article.find_by_id(params[:comment][:article_id]).comments.order("created_at asc")}
		else
			format.js {@article = Article.find_by_id(params[:comment][:article_id])}
		end
	end
end

  private
  	def params_comment
  		params.require(:comment).permit(:content, :article_id, :user_id)
  	end
end
