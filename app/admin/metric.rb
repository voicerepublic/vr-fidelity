ActiveAdmin.register Metric do

  menu priority: 23

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
