ActiveAdmin.register Metric do

  menu priority: 22

  actions :index

  config.batch_actions = false
  config.filters = false
  config.paginate = false

  index as: ActiveAdmin::Views::IndexAsGraph

  controller do
    # fetch all datapoints not older than 1 month
    def scoped_collection
      metrics = Metric.where('created_at > ?', 1.month.ago)
      metrics = Metric.all if metrics.empty? # for development
      metrics
    end
  end

end
