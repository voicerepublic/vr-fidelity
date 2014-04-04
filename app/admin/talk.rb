ActiveAdmin.register Talk do

  action_item only: :show do
    if talk.state == 'postlive'
      link_to 'Postprocess', postprocess_admin_talk_path(talk), method: 'put'
    end
  end

  member_action :postprocess, method: 'put' do
    Delayed::Job.enqueue Postprocess.new(params[:id]), queue: 'audio'
    redirect_to({ action: :show }, { notice: "Placed in queue for postprocessing." })
  end

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
      f.input :starts_at
      f.input :featured_from
      f.input :duration # FIXME make it a select box with discrete values
      f.input :image, as: :dragonfly
      f.input :venue
      f.input :teaser
      f.input :description # FIXME use wysiwyg editor (wysihtml5)
      f.input :record
    end
    f.inputs 'Fields dependent on state' do
      f.input :state, input_html: { disabled: true }
      if f.object.state == 'postlive'
        f.input :started_at
        f.input :ended_at
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
                    ended_at ).map(&:to_sym)

end
