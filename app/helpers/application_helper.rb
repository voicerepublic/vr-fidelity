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

  # takes a string or an obj
  def public_url(suffix)
    suffix = "#{suffix.model_name.plural}/#{suffix.id}" unless suffix.is_a?(String)
    "//#{request.host_with_port}/#{suffix}".sub(':444', '').sub(':3001', ':3000')
  end

end
