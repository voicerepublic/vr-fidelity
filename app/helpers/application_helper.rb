module ApplicationHelper

  # takes a string or an obj
  def public_url(suffix, host=nil)
    host ||= '//'+request.host_with_port
    suffix = "#{suffix.model_name.plural}/#{suffix.id}" unless suffix.is_a?(String)
    "#{host}/#{suffix}".sub(':444', '').sub(':3001', ':3000')
  end

end
