class Section < ActiveRecord::Base

  before_save :set_content_as_html, if: :content_changed?

  def self.locales
    distinct(:locale).pluck(:locale)
  end

  private

  def set_content_as_html
    self.content_as_html = MD2PAGES.render(content)
  end

end
