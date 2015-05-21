class CommentsController < ApplicationController
  def index
  end

  def new

  end

  def edit
  end

  def create
  	respond_to do |format|
		@comment = Comment.new(params_comment)
		if @comment.save
			format.js {@comments = Article.find_by_id(params[:comment][:article_id]).comments.order("id desc")}
		else
			format.js {@article = Article.find_by_id(params[:comment][:article_id])}
		end
	end
end

  private
  	def params_comment
  		params.require(:comment).permit(:user, :content, :article_id)
  	end
end
