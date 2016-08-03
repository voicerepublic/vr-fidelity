ActiveAdmin.register_page "Dashboard" do

  menu priority: 0, label: proc{ I18n.t("active_admin.dashboard") }

  page_action :seed do
    render json: {
      talks:            Talk.in_dashboard.map(&:attributes),
      djAudioQueueSize: Delayed::Job.audio.queued.count,
      postliveCount:    Talk.postlive.count,
      streams:          Talk.live.map(&:streams).flatten
    }
  end

  title = 'WITH GREAT POWER COMES GREAT RESPONSIBILITY'
  content title: title do
    div id: 'livedashboard', style: 'margin: 30px; height: 100%' do
      script do
        x = <<-EOF

        document.fayeUrl = '#{Settings.faye.server}';

        mappings = {
          devices: #{Device.mapping.to_json},
          venues: #{Venue.mapping.to_json}
        }

        briefings = {
          servers: #{EC2.briefing.to_json},
          venues: #{Venue.briefing.to_json},
          talks: #{Talk.briefing.to_json}
        }

        EOF
        x.html_safe
      end
    end
  end
end
