require 'redcarpet'

module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer, extensions = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      strikethrough: true,
      superscript: true
    })
    markdown.render(text).html_safe
  end
end