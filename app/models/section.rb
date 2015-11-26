class Section < ActiveRecord::Base

  self.inheritance_column = :_sti_disabled

  belongs_to :page

  before_save :set_content_as_html, if: :content_changed?

  def label
    "#{key} (#{Page::LANGUAGES[locale.to_sym]})"
  end

  def input_options
    { label: label, as: type }
  end

  private

  def set_content_as_html
    self.content_as_html = MD2PAGES.render(content)
  end

end
