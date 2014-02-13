ActiveAdmin.register Talk do

  index do
    column :id
    column :starts_at, sortable: :starts_at do |talk|
      span style: 'white-space: pre' do
        l talk.starts_at, format: :iso
      end
    end
    # FIXME introduce featured_from for talks
    # column :featured_from, sortable: :featured_from do |talk|
    #   span style: 'white-space: pre' do
    #     l talk.featured_from, format: :iso
    #   end
    # end
    column :duration
    column :title, sortable: :title do |talk|
      truncate talk.title
    end
    column :teaser, sortable: :teaser do |talk|
      truncate talk.teaser
    end
    column :description, sortable: :description do |talk|
      truncate talk.description # FIXME properly display html
    end
    column :featured_from, sortable: :featured_from do |talk|
      l talk.featured_from, format: :iso unless talk.featured_from.nil?
    end
    column :record
    column :venue
    actions
  end

  scope :all
  scope :upcoming
  scope :archived
  scope :featured

  form do |f|
    f.inputs do
      f.input :title
      f.input :starts_at
      f.input :featured_from
      f.input :duration # FIXME make it a select box with discrete values
      f.input :venue
      f.input :teaser
      f.input :description # FIXME use wysiwyg editor (wysihtml5)
      f.input :record
    end
    f.actions
  end
  
  permit_params %w( title
                    starts_at
                    featured_from
                    duration
                    venue_id
                    teaser
                    description
                    record ).map(&:to_sym)
  
end
