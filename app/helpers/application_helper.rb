module ApplicationHelper

  # takes a string or an obj
  def public_url(suffix, host=nil)
    host ||= '//'+request.host_with_port
    suffix = "#{suffix.model_name.plural}/#{suffix.id}" unless suffix.is_a?(String)
    "#{host}/#{suffix}".sub(':444', '').sub(':3001', ':3000')
  end

  def hms(total_seconds)
    Time.at(total_seconds).utc.strftime("%H:%M:%S")
  end

  def estimate_duration(size)
    # based on the observation 1 MB per 87 seconds
    (size / 1024.0 ** 2) * 87
  end

end
