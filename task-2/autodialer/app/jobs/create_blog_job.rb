class CreateBlogJob < ApplicationJob
  queue_as :default

  def perform(title:, author:)
    pplx_service = PerplexityService.new
    resp = pplx_service.gen_blog(title: title)
    Blog.create!(author: author, title: title, description: resp)
  end
end