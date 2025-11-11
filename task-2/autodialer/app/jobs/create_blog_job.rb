class CreateBlogJob < ApplicationJob
  queue_as :default

  def perform(article:)
    pplx_service = PerplexityService.new
    resp = pplx_service.gen_blog(title: article.title)
    article.update!(description: resp, published: true)
  end
end