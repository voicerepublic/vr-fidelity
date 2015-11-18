# https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use

MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(filter_html: true))

# a more permissive renderer
options = {
  hard_wrap: true
}

extensions = {
  lax_spacing: true,
  highlight: true
}

MD2PAGES = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(options), extensions)
