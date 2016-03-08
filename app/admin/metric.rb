ActiveAdmin.register Metric do

  menu priority: 23

  action_item do
    link_to t('.report'), report_admin_metrics_path
  end

  collection_action :report do
    send_data Metric.report.to_yaml
  end

  actions :index

  config.batch_actions = false
  config.filters = false
  config.paginate = false

  index as: ActiveAdmin::Views::IndexAsGraph

  controller do
    # fetch all datapoints not older than 3 months
    def scoped_collection
      metrics = Metric.where('created_at > ?', 3.months.ago)
      metrics = Metric.all if metrics.empty? # for development
      metrics
    end
  end

end
