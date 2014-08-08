class TextInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push('col-sm-6')
  end
end