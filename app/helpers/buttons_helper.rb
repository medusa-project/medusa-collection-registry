#some helpers for producing links/buttons
module ButtonsHelper

  def edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    icon_default_button('Edit', Settings.icons.edit_button, url_or_object, options)
  end

  def small_edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    small_icon_default_button('Edit', Settings.icons.edit_button, url_or_object, options)
  end

  def delete_button(url_or_object, message: nil, options: {})
    message ||= t('default.confirm_message')
    icon_danger_button('Delete', Settings.icons.delete_button, url_or_object, options.reverse_merge(data: {confirm: message}))
  end

  def small_delete_button(url_or_object, message: nil, options: {})
    message ||= t('default.confirm_message')
    small_icon_danger_button('Delete', Settings.icons.delete_button, url_or_object, options.reverse_merge(data: {confirm: message}))
  end

  def view_button(url_or_object)
    icon_default_button('View', Settings.icons.view_button, url_or_object)
  end

  def small_view_button(url_or_object)
    small_icon_default_button('View', Settings.icons.view_button, url_or_object)
  end

  def download_button(url)
    default_button('Download', url)
  end

  def small_download_button(url)
    small_default_button('Download', url)
  end

  def red_flags_button(url)
    icon_default_button('Red Flags', Settings.icons.red_flags_button, url)
  end

  def small_create_button(url)
    small_icon_default_button('Create', Settings.icons.create_button, url)
  end

  def small_add_button(url, options = {})
    small_icon_primary_button('Add', Settings.icons.add_button, url, options)
  end

  def events_button(url)
    icon_default_button('Events', Settings.icons.events_button, url)
  end

  def assessments_button(url)
    default_button('Assessments', url)
  end

  def timeline_button(url)
    icon_default_button('Timeline', Settings.icon.timeline_button, url)
  end

  def attachments_button(url)
    icon_default_button('Attachments', Settings.icons.attachments_button, url)
  end

  def index_button(url)
    default_button('Index', url)
  end

  def small_run_button(url, options = {})
    small_default_button('Run', url, options.reverse_merge(method: :post))
  end

  def small_clone_button(url_or_object, options = {})
    small_icon_default_button('Clone', Settings.icons.clone_button, url_or_object, options.reverse_merge(method: :post))
  end

  def clone_button(url_or_object, options = {})
    icon_default_button('Clone', Settings.icons.clone_button, url_or_object, options.reverse_merge(method: :post))
  end

  def cancel_modal_button
    button_tag('Cancel', type: :button, class: button_class, data: {dismiss: :modal})
  end

  def cancel_modal_x
    button_tag('×', type: :button, class: 'close', data: {dismiss: :modal})
  end

  def cancel_and_go_to_button(path_or_object)
    default_button('Cancel', path_or_object)
  end

  #the label: key goes to the first argument in the submit method
  # the value: key goes as an html attribute
  # I had both usages in the code that I'm refactoring from - I'm not sure if more unification is available here
  def submit_button(form, args = {})
    classes = "btn btn-primary #{args.delete(:class)}".strip!
    label = args.delete(:label)
    form.submit(label, args.merge!(class: classes))
  end

  def submit_modal_button(form, args = {})
    value = args.delete(:value) || 'Submit'
    if object = args.delete(:object)
      value = submit_label(object)
    end
    classes = "btn btn-primary #{args.delete(:class)}".strip!
    form.button :submit, args.merge!(class: classes, type: :submit, value: value, onclick: "hide_modals()")
  end

  def small_danger_button(label, path, args = {})
    generic_button(label, path, 'btn btn-danger btn-xs',
                   args.reverse_merge(role: :button, method: :delete,
                                      data: {confirm: 'Are you sure? This cannot be undone.'},
                                      title: label))
  end

  def icon_danger_button(title, icon, path, args = {})
    generic_button(fa_icon(icon), path, 'btn btn-danger',
                   args.reverse_merge(role: :button, method: :delete,
                                      data: {confirm: 'Are you sure? This cannot be undone.'},
                                      title: title))
  end

  def small_icon_danger_button(title, icon, path, args = {})
    generic_button(fa_icon(icon), path, 'btn btn-danger btn-xs',
                   args.reverse_merge(role: :button, method: :delete,
                                      data: {confirm: 'Are you sure? This cannot be undone.'},
                                      title: title))
  end


  def small_icon_default_button(title, icon, path, args = {})
    generic_button(fa_icon(icon), path, 'btn btn-default btn-xs', args.reverse_merge(title: title))
  end

  def small_default_button(label, path, args = {})
    generic_button(label, path, 'btn btn-default btn-xs', args)
  end

  def icon_default_button(title, icon, path, args = {})
    generic_button(fa_icon(icon), path, 'btn btn-default', args.reverse_merge(title: title))
  end

  def default_button(label, path, args = {})
    generic_button(label, path, 'btn btn-default', args)
  end

  def primary_button(label, path, args = {})
    generic_button(label, path, 'btn btn-primary', args)
  end

  def small_primary_button(label, path, args = {})
    generic_button(label, path, 'btn btn-primary btn-xs', args)
  end

  def small_icon_primary_button(title, icon, path, args = {})
    generic_button(fa_icon(icon), path, 'btn btn-primary btn-xs', args.reverse_merge(title: title))
  end

  protected

  def generic_button(label, path, base_classes, args)
    extra_classes = args.delete(:class)
    classes = [base_classes, extra_classes].join(' ')
    link_to(path, {class: classes, title: label, role: :button}.merge(args)) do
      label
    end
  end

  def button_class
    'btn btn-default'
  end

  def small_button_class
    'btn btn-default btn-xs'
  end

  def submit_label(object)
    object.new_record? ? 'Create' : 'Update'
  end

end