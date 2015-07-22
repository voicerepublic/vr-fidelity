module ApplicationHelper

  def metric(metric, fmt='%d')
    # apply some naming specific number formatting
    fmt = '%.1f%' if metric.key.match(/_percent$/)
    fmt = '%.2f' if metric.key.match(/_per_|_ratio$/)

    content_tag(:e, fmt % metric.value) +
      t('.'+metric.key) +
      link_to(metric.key, admin_metric_path(id: metric.key))
  end

  alias_method :m, :metric

  def public_url(obj)
    ns = obj.model_name.plural
    "//#{request.host_with_port}/#{ns}/#{obj.id}".
      sub(':444', '').sub(':3001', ':3000')
  end

end
