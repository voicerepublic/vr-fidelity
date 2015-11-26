class SerializedTextInput < SerializedInput

  def custom_input_tag
    "<textarea name='#{name}' rows='8'>#{value}</textarea>".html_safe
  end

end
