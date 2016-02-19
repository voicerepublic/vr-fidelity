class Section < ActiveRecord::Base

  before_save :set_content_as_html, if: :content_changed?

  def self.locales
    # ActiveAdmin will puke its guts out when you do this...
    # distinct(:locale).pluck(:locale)
    %w(en de)
  end

  private

  def set_content_as_html
    self.content_as_html = MD2PAGES.render(content)
  end

end
