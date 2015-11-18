class Page < ActiveRecord::Base

  TEMPLATES = %w( default )

  LANGUAGES = {
    en: 'English',
    de: 'Deutsch'
  }

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  validates :template, inclusion: { in: TEMPLATES }
  validates :slug, format: { with: /\A[a-z-]+\z/, on: :update }

  private

  def slug_candidates
    [ :title_en, [:title_en, :id] ]
  end

end
