class ArticlesController < ApplicationController
  def index
  	# @articles = Article.all.order("created_at desc")
  	@articles = Article.page(params[:page]).order("created_at desc")
  	# @articles = Article.paginate(:page => params[:page], :per_page => 10)

  end

  def new
  	@article = Article.new
  end

  def create
  	@article = Article.new(param_article)
  	if @article.save
  		flash[:notice] = "Article successfully created!"
  		redirect_to action: "index"
  	else
  		flash[:error] = "data not valid"
        render "new"
  	end
  end

  def edit
    @article = Article.find_by_id(params[:id])
  end

  def update
    @article = Article.find_by_id(params[:id])
    if @article.update(param_article)
      flash[:notice] = "Article successfully updated!"
      redirect_to action: 'index'
    else
      flash[:error] = "Article successfully updated!"
      render "edit"
    end
  end

  def show
  	@article = Article.find_by_id(params[:id])
  	@comments = @article.comments.order("id desc")
  	@comment = Comment.new
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ArticlePdf.new(@article)
        send_data pdf.render, filename: @article.title, type: 'application/pdf'
      end
    end
  end

  def destroy
  	@article = Article.find_by_id(params[:id])
  	if @article.destroy
        flash[:notice] = "Article successfully deleted"
        redirect_to action: 'index'
    else
        flash[:error] = "fails delete a records"
        redirect_to action: 'index'
    end
  end

  private
  	def param_article
  		params.require(:article).permit(:title, :content)
  	end

end
