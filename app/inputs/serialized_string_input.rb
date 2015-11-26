class SerializedStringInput < SerializedInput

  def custom_input_tag
    "<input type='text' name='#{name}' value='#{value}'>".html_safe
  end

end
