ActiveAdmin.register Venue do

  menu priority: 12

  actions :all, except: [:new, :destroy]

  Venue::STATES.each do |state|
    scope state.to_sym
  end

  filter :id
  filter :name
  filter :slug
  filter :lat
  filter :long

  controller do
    def scoped_collection
      Venue.includes(:talks)
    end
  end

  permit_params :name, :lat, :long, :options, flags: []

  index do
    selectable_column
    column :id
    column :name
    column :lat
    column :long
    column :user
    column :state do |v|
      span v.state, class: 'status_tag '+v.state
    end
    actions
  end

  sidebar "Stream URLs", only: :show do
    ul do
      li { link_to 'Input', venue.stream_url }
      li { link_to 'Output MP3', venue.stream_url.to_s+'.mp3' }
      li { link_to 'Output OGG', venue.stream_url.to_s+'.ogg' }
      li { link_to 'Output AAC', venue.stream_url.to_s+'.aac' }
    end
  end

  sidebar "Danger Zone", only: :show do
    div "Use if venue hangs in DISCONNECT_REQUIRED."
    div class: 'danger_zone' do
      link_to 'Fake Disconnect',
              fake_disconnect_admin_venue_path(venue),
              method: 'put', class: 'danger'
    end

    div "Use if Input can be listened to but Output is mute. This will
         terminate the current Streaming Server and immediately launch
         a new one. Terminating the Streaming Server might cause data
         loss. Special care is needed if this is used during the last
         talk!"
    div class: 'danger_zone' do
      link_to 'Replace Streaming Server',
              replace_streaming_server_admin_venue_path(venue),
              method: 'put', class: 'danger'
    end

    div "Use if venue hangs in CONNECTED after last talk."
    div class: 'danger_zone' do
      link_to 'Shutdown Venue',
              shutdown_venue_admin_venue_path(venue),
              method: 'put', class: 'danger'
    end
  end

  member_action :fake_disconnect, method: 'put' do
    Delayed::Job.enqueue FakeDisconnect.new(id: params[:id]), queue: 'trigger'
  end

  member_action :replace_streaming_server, method: 'put' do
    Delayed::Job.enqueue ReplaceStreamingServer.new(id: params[:id]), queue: 'trigger'
  end

  member_action :shutdown, method: 'put' do
    Delayed::Job.enqueue ShutdownVenue.new(id: params[:id]), queue: 'trigger'
  end

  show do |v|
    attributes_table do
      row :id
      row :name
      row :slug
      #row :lat
      #row :long
      row :user
      row :state
      row :client_token
      row :instance_id
      row :mount_point
      row :public_ip_address
      row :source_password
      row :admin_password
      row :instance_type
      row :device_name
      row :device
      row :stream_url
      row :flags do
        badges = Venue::FLAGS.map do |f|
          state = v.flags.include?(f) ? ' active' : ''
          content_tag :span, f.humanize,
                      class: "badge" + state
        end
        raw badges * ' '
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :name
      # f.input :user
      # f.input :slug
      f.input :lat
      f.input :long
      f.input :options, input_html: { rows: 6 },
              hint: "Boolean flags will be set/overriden by the checkboxes below."
      # FIXME selected options are not properly checkmarked
      f.input :flags, as: :check_boxes, collection: Venue::FLAGS,
              member_label: :humanize,
              hint: "Please consult the event handbook for details on these options."
    end
    f.actions
  end

end
