class BlogsController < ApplicationController
  def new
    @blogs = Blog.all
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
      CreateBlogJob.perform_later(title: title, author: author)
    end
  end
end
