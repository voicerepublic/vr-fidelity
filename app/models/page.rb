class Page < ActiveRecord::Base

  TEMPLATES = %w( default )

  MARKDOWN_FIELDS = %w( content )

  LANGUAGES = {
    en: 'English',
    de: 'Deutsch'
  }

  TEMPLATES.each do |template|
    scope template, -> { where(template: template) }
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  validates :template, inclusion: { in: TEMPLATES }
  validates :slug, format: { with: /\A[a-z-]+\z/, on: :update }

  before_save :htmlify

  private

  def slug_candidates
    [ :title_en, [:title_en, :id] ]
  end

  def htmlify
    LANGUAGES.each do |locale, language|
      MARKDOWN_FIELDS.each do |field|
        attr = [field, locale] * '_'
        next unless send("#{attr}_changed?")
        self["#{attr}_as_html"] = MD2PAGES.render(send(attr))
      end
    end
  end

end
