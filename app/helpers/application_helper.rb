module ApplicationHelper

  def link_to_external(name, url, opts = {})
    link_to name, external_url(url), opts.merge(target: '_blank')
  end

  def fa_icon_link_to(title, icon, url, html_opts = {})
    link_to url, html_opts.merge(title: title) do
      fa_icon icon
    end
  end

  #if url doesn't contain the protocol then add it here
  def external_url(url)
    if url.blank?
      ''
    else
      url.match(/^http(s?):\/\//) ? url : "http://#{url}"
    end
  end

  #standard way to render a value in a show view
  def show_value(value, label)
    render 'shared/show_value', label: label, value: value
  end

  #standard way to render a field of a model in a show view, with custom label if needed
  def show_field(model, field, label = nil)
    label ||= field.to_s.titlecase
    show_value(model.send(field), label)
  end

  def show_present_value(value, label)
    show_value(value, label) if value.present?
  end

  def show_present_field(model, field, label = nil)
    show_field(model, field, label) if model.send(field).present?
  end

  def generic_confirm_message
    'This is irreversible - are you sure?'
  end

  def wiki_link(label)
    link_to label, 'https://wiki.cites.uiuc.edu/wiki/display/LibraryDigitalPreservation/Home', target: '_blank'
  end

  def date_picker_options(extra_opts = {})
    {as: :string, input_html: {'data-datepicker' => 'datepicker'},
     order: [:day, :month, :year], use_month_numbers: true}.merge(extra_opts)
  end

  #Use in place of Cancan's can? so that it will work when there is not a user (in this case permission is denied, as you'd expect)
  def safe_can?(action, *args)
    current_user and (can?(action, *args))
  end

  def cache_key_for_all(klass)
    count = klass.count
    max_updated_at = klass.maximum(:updated_at)
    "#{klass.to_s.pluralize.underscore}/all-#{count}-#{max_updated_at}"
  end

end
