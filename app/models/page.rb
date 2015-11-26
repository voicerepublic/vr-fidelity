class Page < ActiveRecord::Base

  # `title` is special, every type must have it
  TYPE_SECTIONS = {
    # landing_page: {
    #   title: :string,
    #   top_section: :text,
    #   bottom_section: :text
    # },
    default: {
      title: :string,
      main: :text
    }
  }

  LANGUAGES = {
    #fr: 'Francais',
    en: 'English',
    de: 'Deutsch'
  }

  # ------------------------------

  TYPES = TYPE_SECTIONS.keys.map(&:to_s)

  self.inheritance_column = :_sti_disabled

  # TODO maybe introduce position to control order
  has_many :sections, -> { order('locale, id') }, dependent: :destroy

  accepts_nested_attributes_for :sections

  after_initialize :set_defaults, if: :new_record?
  after_initialize :populate_missing

  before_save :set_content

  TYPES.each do |type|
    scope type, -> { where(type: type) }
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  validates :type, inclusion: { in: TYPES }
  validates :initial_title, presence: true, allow_blank: false
  validates :slug, format: { with: /\A[0-9a-z-]+\z/, on: :update }

  def title
    section = sections.find_by(key: 'title', locale: 'en')
    return nil unless section
    section.content_as_html.html_safe
  end

  def section(key)
    (sections.find_by(key: key, locale: 'en').content_as_html || '').html_safe
  end

  private

  def set_defaults
    self.type ||= 'default'
  end

  def populate_missing
    LANGUAGES.each do |locale, language|
      TYPE_SECTIONS[type.to_sym].each do |key, section_type|
        attrs = { locale: locale, key: key, type: section_type }
        section = sections.find_or_initialize_by(attrs)
        # use the initial_title for title fields
        section.content ||= initial_title if key == :title
      end
    end
  end

  def slug_candidates
    [ :initial_title,
      [:type, :initial_title],
      [:initial_title, :id] ]
  end

  # the sum of all sections of all locales for simple searchabilty
  def set_content
    self.content = sections.map(&:content).join(' ')
  end

end
