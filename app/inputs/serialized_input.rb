class SerializedInput < Formtastic::Inputs::StringInput

  def to_html
    input_wrapping do
      label_html <<
        custom_input_tag
    end
  end

  private

  def custom_input_tag(*args)
    raise 'this needs to be subclassed'
  end

  # e.g. "content['en']['main']"
  def value_code
    path = method.to_s.split('-')
    attr = path.shift
    ([attr] + path.map { |s| "['#{s}']" }) * ''
  end

  def value
    object.instance_eval(value_code)
  end

  # e.g. "page[content][en][main]"
  def name
    path = method.to_s.split('-')
    ([namespace] + path.map { |s| "[#{s}]" }) * ''
  end

  # e.g. "content en main"
  def label_text
    method.to_s.gsub('-', ' ')
  end

  # e.g. "page"
  def namespace
    object.class.base_class.model_name.element
  end

end
