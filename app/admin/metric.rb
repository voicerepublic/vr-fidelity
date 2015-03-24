ActiveAdmin.register Metric do

  menu priority: 21

  # make ApplicationHelper reload properly
  #
  # see https://github.com/activeadmin/activeadmin/issues/697
  #
  controller { helper ApplicationHelper }

  actions :index, :show

  config.batch_actions = false
  config.filters = false

  index as: :grid, columns: 5 do |metric|
    div m(metric), class: 'panel figure'
  end

  # make show render partial app/views/admin/metrics/_show
  show do
    render 'show'
  end

  controller do
    # this resource is actually a collection
    def resource
      Metric.where(key: params[:id]).order('created_at DESC').limit(90)
    end

    # only fetch the latest metrics
    def scoped_collection
      max_created_at = Metric.maximum(:created_at)
      Metric.where('created_at > ?', max_created_at - 2.hours)
    end
  end

end
