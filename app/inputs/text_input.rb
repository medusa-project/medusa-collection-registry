class TextInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push('col-md-6')
  end
end