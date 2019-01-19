#some helpers for producing links/buttons
module ButtonsHelper

  def edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', Settings.icons.edit_button, url_or_object, options.reverse_merge(class: button_class)
  end

  def small_edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', Settings.icons.edit_button, url_or_object, options.reverse_merge(class: small_button_class)
  end

  def delete_button(url_or_object, message: nil, options: {})
    message ||= t('default.confirm_message')
    fa_icon_link_to 'Delete', Settings.icons.delete_button, url_or_object, options.reverse_merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger')
  end

  def small_delete_button(url_or_object, message: nil, options: {})
    message ||= t('default.confirm_message')
    fa_icon_link_to 'Delete', Settings.icons.delete_button, url_or_object, options.reverse_merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger btn-xs')
  end

  def view_button(url_or_object)
    fa_icon_link_to 'View', Settings.icons.view_button, url_or_object, class: button_class
  end

  def small_view_button(url_or_object)
    fa_icon_link_to 'View', Settings.icons.view_button, url_or_object, class: small_button_class
  end

  def download_button(url)
    link_to 'Download', url, class: button_class, role: :button
  end

  def small_download_button(url)
    link_to 'Download', url, class: small_button_class, role: :button
  end

  def red_flags_button(url)
    fa_icon_link_to 'Red Flags', Settings.icons.red_flags_button, url, class: button_class
  end

  def small_create_button(url)
    fa_icon_link_to 'Create', Settings.icons.create_button, url, class: small_button_class
  end

  def add_button(url, options = {})
    fa_icon_link_to 'Add', Settings.icons.add_button, url, options.reverse_merge(class: button_class)
  end

  def small_add_button(url, options = {})
    fa_icon_link_to 'Add', Settings.icons.add_button, url, options.reverse_merge(class: small_button_class)
  end

  def events_button(url)
    fa_icon_link_to 'Events', Settings.icons.events_button, url, class: button_class
  end

  def assessments_button(url)
    link_to 'Assessments', url, class: button_class, role: :button
  end

  def attachments_button(url)
    fa_icon_link_to 'Attachments', Settings.icons.attachments_button, url, class: button_class
  end

  def index_button(url)
    link_to 'Index', url, class: button_class, role: :button
  end

  def small_run_button(url, options = {})
    link_to 'Run', url, options.reverse_merge(method: :post, class: small_button_class, role: :button)
  end

  def small_clone_button(url_or_object, options = {})
    fa_icon_link_to('Clone', Settings.icons.clone_button, url_or_object, options.reverse_merge(class: small_button_class, method: :post))
  end

  def clone_button(url_or_object, options = {})
    fa_icon_link_to('Clone', Settings.icons.clone_button, url_or_object, options.reverse_merge(class: button_class, method: :post))
  end

  def cancel_modal_button
    button_tag('Cancel', type: :button, class: button_class, data: {dismiss: :modal})
  end

  def cancel_modal_x
    button_tag('×', type: :button, class: 'close', data: {dismiss: :modal})
  end

  def cancel_and_go_to_button(path_or_object)
    link_to('Cancel', path_or_object, class: button_class, role: :button)
  end

  def submit_button(form, args = {})
    value = args.delete(:value) || 'Submit'
    classes = "btn btn-primary #{args.delete(:class)}".strip!
    form.submit(args.merge!(value: value, class: classes))
  end

  def submit_button_2(form, args = {})
    args.merge!(class: 'btn btn-primary')
    form.button(:submit, args)
  end

  def submit_button_3(form, label, args = {})
    classes = "btn btn-primary #{args.delete(:class)}".strip!
    form.submit(label, args.merge!(class: classes))
  end

  def submit_modal_button(form, args = {})
    value = args.delete(:value) || 'Submit'
    classes = "btn btn-primary #{args.delete(:class)}".strip!
    form.button :submit, args.merge!(class: classes, 'data-hide': 'modal', type: :submit, value: value)
  end

  def submit_modal_button_2(form, args = {})
    value = args.delete(:value) || 'Submit'
    if object = args.delete(:object)
      value = submit_label(object)
    end
    classes = "btn btn-primary #{args.delete(:class)}".strip!
    form.button :submit, args.merge!(class: classes, type: :submit, value: value, onclick: "hide_modals()", value: value)
  end

  def submit_label(object)
    object.new_record? ? 'Create' : 'Update'
  end

  protected

  def button_class
    'btn btn-default'
  end

  def small_button_class
    'btn btn-default btn-xs'
  end

end