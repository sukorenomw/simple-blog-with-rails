class ArticlesController < ApplicationController
  before_filter :require_login, :only => [:new, :create, :edit, :update,
:delete, :destroy]

  def index
  	# @articles = Article.all.order("created_at desc")
  	@articles = Article.page(params[:page]).order("updated_at desc")
  	# @articles = Article.paginate(:page => params[:page], :per_page => 10)
  end

  def download_article
    if params[:article].present?
      @articles = Article.where(:id => params[:article])
      @comments = @articles.first.comments
      @name = @articles.first.title
    else
      @articles = Article.all
      @comments = Comment.all
      @name = "All articles"
    end
    respond_to do |format|
      format.html
      format.xlsx do
        xlsx = Axlsx::Package.new
        wb = xlsx.workbook
        wb.add_worksheet(name: "Articles") do |sheet|
          sheet.add_row ["ID", "Title", "Content", "User ID","Created At", "Updated At", "Username"]
          @articles.each do |article|
            sheet.add_row [article.id, article.title, article.content, article.user.id, article.created_at, article.updated_at, article.user.username]
          end
        end
        wb.add_worksheet(name: "Comments") do |sheet|
          sheet.add_row ["ID", "Article ID", "Content", "User ID", "Created At", "Updated At", "Username"]
          @comments.each do |comment|
            sheet.add_row [comment.id, comment.article_id, comment.content, comment.user.id, comment.created_at, comment.updated_at, comment.user.username]
          end
        end

        send_data xlsx.to_stream.read, type: "application/xlsx", filename: "#{@name}.xlsx"
      end
    end
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
  	@comments = @article.comments.order("created_at asc")
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

  def import
    if params[:file].nil?
      flash[:error] = "No file imported!"
      redirect_to action: 'index'
    else
      total_row = 0
      spreadsheet = open_spreadsheet(params[:file])

      if spreadsheet
        spreadsheet.sheets.each_with_index do |sheet, index|
          spreadsheet.default_sheet = spreadsheet.sheets[index]

          header = Array.new
          spreadsheet.row(1).each { |row| header << row.downcase.tr(' ', '_') }
          (2..spreadsheet.last_row).each do |i|
            row = Hash[[header, spreadsheet.row(i)].transpose]

            @content = eval("#{spreadsheet.default_sheet.singularize}").find_by_id(row["id"].to_i)

            if @content.present?
              @content.update(title: row["title"].to_s, content: row["content"].to_s, user_id: row["user_id"].to_i)
              # raise "#{row}"
            else
              new_row = eval("#{spreadsheet.default_sheet.singularize}").new(row)
              new_row.save!
            end
            # new_row = eval("#{spreadsheet.default_sheet.singularize}").new(row)
            # raise "tes #{row[]}"
            # # raise 'Failed to save, maybe invalid column' unless new_row.save!
            # if new_row.valid?
            #   raise "tes"
            # else
            #   raise "#{new_row.errors}"
            # end

            total_row += 1
          end
        end
        redirect_to root_url, notice: "Total #{total_row} records imported."
      else
        redirect_to root_url, :flash => { :error => "File not supported."}  
      end
    end  
  end

  private
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when '.csv' then Roo::Csv.new(file.path, {extension: :csv, file_warning: :ignore })
        when '.xls' then Roo::Excel.new(file.path, {extension: :xls, file_warning: :ignore })
        when '.xlsx' then Roo::Excelx.new(file.path, {extension: :xlsx, file_warning: :ignore })
        else false
      end
    end

  	def param_article
  		params.require(:article).permit(:title, :content, :user_id)
  	end

end
