class TextInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push('span6')
  end
end