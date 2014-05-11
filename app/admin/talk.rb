ActiveAdmin.register Talk do

  action_item only: :show do
    if talk.state == 'postlive'
      link_to 'Postprocess', postprocess_admin_talk_path(talk), method: 'put'
    end
  end

  action_item only: :show do
    if talk.state == 'archived'
      link_to 'Reprocess', reprocess_admin_talk_path(talk), method: 'put'
    end
  end

  member_action :postprocess, method: 'put' do
    Delayed::Job.enqueue Postprocess.new(params[:id]), queue: 'audio'
    redirect_to({ action: :show }, { notice: "Placed in queue for postprocessing." })
  end

  member_action :reprocess, method: 'put' do
    Delayed::Job.enqueue Reprocess.new(params[:id]), queue: 'audio'
    redirect_to({ action: :show }, { notice: "Placed in queue for reprocessing." })
  end

  index do
    column :id
    column :uri do |talk|
      # TODO check absolute url
      link_to talk.uri, "https://#{request.host}/talk/#{talk.id}"
    end
    column :starts_at, sortable: :starts_at do |talk|
      span style: 'white-space: pre' do
        l talk.starts_at, format: :iso
      end
    end
    column :duration
    column :title, sortable: :title do |talk|
      truncate talk.title
    end
    column :teaser, sortable: :teaser do |talk|
      truncate talk.teaser
    end
    column :featured_from, sortable: :featured_from do |talk|
      span style: 'white-space: pre' do
        l talk.featured_from, format: :iso unless talk.featured_from.nil?
      end
    end
    column :record
    column :venue
    column :state
    actions
  end

  scope :all
  scope :featured

  scope :prelive
  scope :live
  scope :postlive
  scope :processing
  scope :archived

  form do |f|
    f.inputs do
      f.input :title
      f.input :starts_at,
              as: :string,
              input_html: {
                class: 'picker',
                value: f.object.starts_at.strftime("%Y-%m-%d %H:%M:%S")
              }
      f.input :featured_from,
              as: :string,
              input_html: {
                class: 'picker',
                value: f.object.featured_from &&
                f.object.featured_from.strftime("%Y-%m-%d %H:%M:%S")
              }
      f.input :duration # FIXME make it a select box with discrete values
      f.input :venue
      f.input :teaser
      f.input :description # FIXME use wysiwyg editor (wysihtml5)
      f.input :record
      f.input :recording_override, hint: 'paste a URL to import a manually processed file, e.g. a dropbox URL'
      f.input :related_talk_id, as: :string, hint: 'ID of related talk'
    end
    f.inputs 'Image' do
      f.input :image, as: :dragonfly
    end
    f.inputs 'Fields dependent on state' do
      f.input :state, input_html: { disabled: true }
      if %w(postlive archived).include? f.object.state
        f.input :started_at,
          as: :string,
          input_html: {
            class: 'picker',
            value: f.object.started_at.try(:strftime, "%Y-%m-%d %H:%M:%S")
          }
        f.input :ended_at,
          as: :string,
          input_html: {
            class: 'picker',
            value: f.object.ended_at.try(:strftime, "%Y-%m-%d %H:%M:%S")
          }
      end
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
                    record
                    started_at
                    ended_at
                    image
                    related_talk_id
                    retained_image
                    remove_image
                    recording_override ).map(&:to_sym)

end
