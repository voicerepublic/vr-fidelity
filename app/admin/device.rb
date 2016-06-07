ActiveAdmin.register Device do

  LOGLEVELS = {
    '5 - unknown' => 5,
    '4 - fatal'   => 4,
    '3 - error'   => 3,
    '2 - warn'    => 2,
    '1 - info'    => 1,
    '0 - debug'   => 0
  }

  menu parent: 'Admin'

  actions :all, except: [:new, :destroy]

  permit_params %w( name
                    organization_id
                    target
                    loglevel
                    report_interval
                    heartbeat_interval
                    options ).map(&:to_sym)

  # sidebar :actions, only: :show do
  #   button t('.shutdown')
  #   button t('.reboot')
  #   button t('.restart')
  # end

  show do
    attributes_table do
      row :id
      row :name
      row :identifier
      row :type
      row :subtype
      row :state
      row :target
      row :loglevel do |d|
        LOGLEVELS.invert[d.loglevel]
      end
      row :report_interval
      row :heartbeat_interval
      row :public_ip_address
      row :organization
      row :created_at
      row :updated_at
      row :last_heartbeat_at
      row :disappeared_at
      row :paired_at
    end
    # TODO show only in online states
    panel 'REPL' do
      div id: 'repl' do
        div id: 'log' do
          div id: 'bottom'
        end
        input id: 'code'
      end
    end
    panel 'Status' do
      div id: 'report' do
        'Awaiting report...'
      end
    end
    active_admin_comments
    script src: Settings.faye.server + '/client.js'
    script do
      "fayeUrl = '#{Settings.faye.server}';
       device = #{device.attributes.to_json}".html_safe
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :organization
      f.input :target, hint: t('.hint_target'), collection: %w(live staging dev)
      f.input :loglevel, hint: t('.hint_loglevel'), as: :select, collection: LOGLEVELS
      f.input :report_interval
      f.input :heartbeat_interval
      f.input :options
    end
    f.actions
  end

  controller do
    after_action :propagate_restart, only: :update

    def propagate_restart
      Faye.publish_to "/device/#{resource.identifier}", event: 'exit'
    end
  end

end
