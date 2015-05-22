class ArticlePdf < Prawn::Document
  include Prawn::View

  def initialize(article)
    super()
    @article = article
    header
    text_content
  end
 
  def header
    image "#{Rails.root}/public/assets/img/home-bg.jpg", width: 530, height: 150
    move_up 80
    font "Helvetica"
    text @article.title, :align => :center, :size => 32, :color => "FFFFFF", style: :bold
    text "Posted by Admin on "+Date.strptime("#{@article.updated_at}","%Y-%m-%d %H:%M:%S %Z").strftime("%A, %m %B %Y"), :align => :center, :size => 14, :color => "FFFFFF"
    move_down 30
  end
 
  def text_content
    # The cursor for inserting content starts on the top left of the page. Here we move it down a little to create more space between the text and the image inserted above
    y_position = cursor - 50
 
    # The bounding_box takes the x and y coordinates for positioning its content and some options to style it
    content = @article.content.html_safe
    text content, :align => :justify

    move_down 20
    text "Comments : ", :align => :left, :size => 20, style: :bold
    @article.comments.each do | comment |
      text comment.user, :size => 14, style: :bold
      text comment.content
      
      stroke do
        horizontal_rule
      end
      move_down 10
    end

 
  end
end