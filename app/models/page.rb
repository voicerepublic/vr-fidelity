class Page < ActiveRecord::Base

  # TODO it would be nicer to have these in a class_attribute or
  # cattr_accessor
  #
  # this must list all the fields of all the subclasses of page,
  # mainly for strong_parameters
  PERMITTED_FIELDS = %w( headline
                         main )

  LANGUAGES = {
    en: 'English',
    de: 'Deutsch'
  }

  # this might only work for eager loading
  # TYPES = Page.subclasses.map(&:name)
  # so for know you have to register subclasses here
  TYPES = %w( Pages::Default )

  serialize :title
  serialize :content
  serialize :content_as_html

  # create a scope for each type
  TYPES.each do |type|
    scope type, -> { where(type: type) }
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  validates :type, inclusion: { in: TYPES }
  validates :slug, format: { with: /\A[0-9a-z-]+\z/, on: :update }

  after_initialize :populate_defaults
  before_save :htmlify

  def title_en
    title['en']
  end

  def content_fields
    {}
    #raise 'class page needs to be subclassed!'
  end

  private

  def slug_candidates
    [ :title_en, [:title_en, :id] ]
  end

  def htmlify
    self.content_as_html ||= {}
    LANGUAGES.each do |locale, language|
      self.content_as_html[locale.to_s] ||= {}
      content_fields.each do |field, type|
        self.content_as_html[locale.to_s][field.to_s] =
          MD2PAGES.render(content[locale.to_s][field.to_s])
      end
    end
  end

  def populate_defaults
    self.title ||= {}
    self.content ||= {}
    LANGUAGES.each do |locale, language|
      self.title[locale.to_s] ||= ''
      self.content[locale.to_s] ||= {}
      content_fields.each do |field, type|
        self.content[locale.to_s][field.to_s] ||= ''
      end
    end
  end

end
