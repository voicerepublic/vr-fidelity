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

  action_item :unpair, only: :show do
    unless device.state == 'unpaired'
      link_to 'Unpair', action: 'unpair'
    end
  end

  member_action :unpair do
    device = Device.find(params[:id])
    device.unpair!
    redirect_to action: :show, notice: "Device now unpaired."
  end

  permit_params %w( name
                    organization_id
                    target
                    loglevel
                    report_interval
                    heartbeat_interval
                    options ).map(&:to_sym)

  index do
    selectable_column
    column :name
    column :type
    column :subtype
    column :identifier
    column :pairing_code
    column :disappeared_at do |d|
      unless d.disappeared_at
        span t('.online'), class: 'status_tag green'
      else
        d.disappeared_at
      end
    end
    column :state do |device|
      span device.state, class: 'status_tag '+device.state
    end
    actions
  end

  # sidebar :actions, only: :show do
  #   button t('.shutdown')
  #   button t('.reboot')
  #   button t('.restart')
  # end

  show do
    columns do
      column do
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
          row :pairing_code
          row :paired_at
        end
        panel 'Backup Recordings' do
          table do
            tr do
              th 'Name'
              th 'Start'
              th 'Duration*',
                 title: 'Estimated based on size. Actual duration might differ.'
              th 'Size'
            end
            device.backup_recordings.each do |rec|
              tr do
                td link_to rec.key, "/backup/#{rec.key}", target: '_blank'
                td Time.at(rec.key.match(/_(\d+)\.ogg$/)[1].to_i)
                td hms(estimate_duration(rec.content_length))
                td number_to_human_size(rec.content_length)
              end
            end
          end
        end
      end
      column do
        panel 'REPL' do
          div id: 'repl' do
            div id: 'log' do
              div id: 'bottom'
            end
            input id: 'code'
          end
        end
        panel 'Debug Log' do
          div id: 'debuglog' do
          end
        end
        panel 'Status' do
          div id: 'report' do
          end
        end
        active_admin_comments
        script src: Settings.faye.server + '/client.js'
        script do
          "fayeUrl = '#{Settings.faye.server}';
           device = #{device.attributes.to_json}".html_safe
        end
      end
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
