class Page < ActiveRecord::Base

  TEMPLATES = %w( default )

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged]

  private

  def slug_candidates
    [ :title_en, [:title_en, :id] ]
  end

end
