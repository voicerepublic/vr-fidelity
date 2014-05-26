ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  title = 'WITH GREAT POWER COMES GREAT RESPONSIBILITY'
  content title: title do

    div do
      script do
        raw 'window.talks = ' + Talk.live.map(&:attributes).to_json
      end
    end

    div id: 'notifications', style: 'margin: 30px' do
        subscribe_to("/notifications")       # notifications from rtmpd
    end
    
    div id: 'livedashboard', style: 'margin: 30px' do
      namespaces = [
        "/monitoring", # generic monitoring namespace (depr.)
        "/dj",         # hooks in MonitoredJob
        "/event/talk"  # state changes of talks
      ]        
      (namespaces.map { |ns| subscribe_to(ns) } * "\n").html_safe
    end

    # div :class => "blank_slate_container", :id => "dashboard_default_message" do
    #   span :class => "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
