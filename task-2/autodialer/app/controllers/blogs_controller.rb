class BlogsController < ApplicationController
  def new
    @blogs = Blog.order(:created_at)
  end

  def show
    @blog = Blog.find(params[:id])
  end

  def create
    input = params[:blogs]
    author = params[:author]
    list_input = input.to_s.split("\n")
    titles = list_input.map(&:strip).reject(&:blank?)

    titles.each do |title|
      article = Blog.create!(title: title, author: author)
      CreateBlogJob.perform_later(article: article)
    end

    respond_to do |format|
      format.turbo_stream { render inline: "" }
    end
  end
end
