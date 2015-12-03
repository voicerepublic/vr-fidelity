ActiveAdmin.register Talk do

  menu priority: 13

  actions :all, except: [:new, :destroy]

  permit_params %w( title
                    starts_at
                    featured_from
                    duration
                    venue_id
                    series_id
                    language
                    teaser
                    description
                    started_at
                    ended_at
                    image
                    related_talk_id
                    retained_image
                    remove_image
                    tag_list
                    format
                    speakers
                    slides_uuid
                    penalty
                    recording_override ).map(&:to_sym)

  filter :id
  filter :uri
  filter :slug
  filter :title
  #filter :venue
  filter :featured_from
  filter :starts_at
  filter :ends_at
  filter :started_at
  filter :ended_at
  filter :teaser
  filter :description
  filter :speakers
  filter :language, as: :select, collection: %w(en de fr it es)

  # BEGIN CSV Import
  action_item :import, only: :index do
    link_to 'Import CSV', action: 'import_csv'
  end

  collection_action :import_csv, method: [:get, :post] do
    if params[:dump]
      begin
        file = params[:dump][:file]
        defaults = { state: :prelive }
        transformers = { description: 'html2md' }

        message = Talk.import(file, defaults, transformers)
        if message[:created] or message[:updated]
          flash[:notice] = "#{message[:created]} talk(s) created, " +
                           "#{message[:updated]} talk(s) updated."
          redirect_to action: :index
        end
        @errors = message[:error]
      rescue Exception => e
        flash[:error] = e.message
      end
    end
  end
  # END CSV Import

  action_item :end_talk, only: :show do
    if talk.state == 'live'
      link_to 'End Talk', end_talk_admin_talk_path(talk), method: 'put'
    end
  end

  action_item :postprocess, only: :show do
    if talk.state == 'postlive' && talk.recording_override.blank?
      link_to 'Postprocess', postprocess_admin_talk_path(talk), method: 'put'
    end
  end

  action_item :reprocess, only: :show do
    if talk.state == 'archived' && talk.recording_override.blank?
      link_to 'Reprocess', reprocess_admin_talk_path(talk), method: 'put'
    end
  end

  member_action :end_talk, method: 'put' do
    Delayed::Job.enqueue EndTalk.new(id: params[:id]), queue: 'trigger'
    redirect_to({action: :show}, { notice: "Placed in queue to end talk." })
  end

  member_action :postprocess, method: 'put' do
    Delayed::Job.enqueue Postprocess.new(id: params[:id]), queue: 'audio'
    redirect_to({ action: :show }, { notice: "Placed in queue for postprocessing." })
  end

  member_action :reprocess, method: 'put' do
    Delayed::Job.enqueue Reprocess.new(id: params[:id]), queue: 'audio'
    redirect_to({ action: :show }, { notice: "Placed in queue for reprocessing." })
  end

  scope :all
  scope :featured
  scope :uncategorized
  Talk::STATES.each { |state| scope state.to_sym }

  index do
    selectable_column
    column :id
    column :uri
    column :starts_at, sortable: :starts_at do |talk|
      span style: 'white-space: pre' do
        l talk.starts_at, format: :iso
      end
    end
    column :title, sortable: :title do |talk|
      truncate talk.title
    end
    #column :teaser, sortable: :teaser do |talk|
    #  truncate talk.teaser
    #end
    column :featured_from, sortable: :featured_from do |talk|
      span style: 'white-space: pre' do
        l talk.featured_from, format: :iso unless talk.featured_from.nil?
      end
    end
    column :venue do |talk|
      talk.venue.try(:name)
    end
    column :series
    column :play_count
    column :state
    actions do |talk|
      link_to "&#10148; Public".html_safe, public_url(talk), target: '_blank'
    end
  end

  sidebar :social, only: :show, if: ->{ talk.state == 'archived' } do
    svg id: 'social'
    script "listeners = #{talk.listeners_for_json.to_json}".html_safe
    talk.speakers
    ul do
      talk.social_links.each do |link|
        li do
          link_to link, link
        end
      end
    end
  end

  show do
    if %w(postlive processing archived).include?(talk.state)
      div id: 'visual' do
        script do
          [
            "data = #{talk.storage.values.to_json}",
            "startedAt = #{talk.started_at.to_i}",
            "endedAt = #{talk.ended_at.to_i}",
            "override = #{talk.recording_override?}"
          ].join(";\n").html_safe
        end
      end
    end
    attributes_table do
      row :id
      row :uri do
        (talk.uri + ' ' +
         link_to('&#10148; Public'.html_safe,
                 public_url(talk), target: '_blank')).html_safe
      end
      row :tag_list
      row :state
      row :featured_from
      row :starts_at
      row :ends_at
      row :venue
      row :user
      row :series
      row :title
      row :teaser
      row :description
      row :language
      row :related_talk_id
      row 'download' do
        url = public_url "vrmedia/#{talk.id}-clean.mp3"
        link_to '&#10148; mp3'.html_safe, url, target: '_blank'
      end
      row 'download' do
        url = public_url "vrmedia/#{talk.id}-clean.ogg"
        link_to '&#10148; ogg'.html_safe, url, target: '_blank'
      end
      row :started_at
      row :format
      row :speakers
      row :penalty
      if %w(postlive processing archived).include?(talk.state)
        row :ended_at
        row :processed_at
        row :recording
        row :recording_override
        row :play_count
        # row :flv_data do
        #   number_to_human_size(talk.flv_data[0]) +
        #     ' (' + talk.flv_data[1] + ')'
        # end
        row :disk_usage do
          number_to_human_size talk.disk_usage
        end
        row :files do
          if talk.storage.is_a?(Hash)
            table do
              keys = talk.storage.keys.sort
              keys.each do |key|
                meta = talk.storage[key]
                tr do
                  td meta[:key]
                  td meta[:size]
                  td meta[:duration]
                  td meta[:start] && Time.at(meta[:start].to_i)
                end
              end
            end
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :tag_list, input_html: { value: f.object.tag_list * ', ' }, label: "Tags"
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
      #f.input :series # removed for speed, if needed use something like select2
      f.input :venue, collection: f.object.user.venues
      f.input :teaser
      f.input :language, collection: %w(en de fr it es)
      f.input :description # FIXME use wysiwyg editor (wysihtml5)
      f.input :speakers
      f.input :recording_override,
              hint: 'Paste a URL to import a manually'+
              ' processed file, e.g. a dropbox URL.'
      f.input :slides_uuid, label: 'Slides',
              hint: 'Paste a URL to import slides, e.g. a dropbox URL. (PDF only!)'
      f.input :related_talk_id, as: :string, hint: 'ID of related talk'
      f.input :penalty, hint: "1 = no penalty, 0 = max penalty (I know, it's confusing.) Applies only to this talk."
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

  csv do
    column :id
    column :uri
    column :play_count
    column :popularity
    column :title
    column :featured_from
    column :starts_at
    column :ends_at
    column :started_at
    column :ended_at
    column :language
    column :teaser
    column :description
    column :related_talk_id
    column :speakers
    column :tag_list
  end

  controller do
    helper ApplicationHelper
    def scoped_collection
      Talk.includes(:series, :venue)
    end
  end

end
