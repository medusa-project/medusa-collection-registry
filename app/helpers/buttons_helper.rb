#some helpers for producing links/buttons
module ButtonsHelper

  def edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', 'pencil-square-o', url_or_object, options.reverse_merge(class: 'btn btn-default')
  end

  def small_edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', 'pencil-square-o', url_or_object, options.reverse_merge(class: 'btn btn-default btn-xs')
  end

  def delete_button(url_or_object, message: nil, options: {})
    message ||= generic_confirm_message
    fa_icon_link_to 'Delete', 'trash-o', url_or_object, options.reverse_merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger')
  end

  def small_delete_button(url_or_object, message: nil, options: {})
    message ||= generic_confirm_message
    fa_icon_link_to 'Delete', 'trash-o', url_or_object, options.reverse_merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger btn-xs')
  end

  def index_button(url)
    link_to 'Index', url, class: 'btn btn-default'
  end

  def view_button(url_or_object)
    fa_icon_link_to 'View', 'eye', url_or_object, class: 'btn btn-default'
  end

  def small_view_button(url_or_object)
    fa_icon_link_to 'View', 'eye', url_or_object, class: 'btn btn-default btn-xs'
  end

  def download_button(url)
    link_to 'Download', url, class: 'btn btn-default'
  end

  def small_download_button(url)
    link_to 'Download', url, class: 'btn btn-default btn-xs'
  end

  def red_flags_button(url)
    fa_icon_link_to 'Red Flags', 'flag', url, class: 'btn btn-default'
  end

  def back_button(url_or_object)
    link_to 'Back', url_or_object, class: 'btn btn-default'
  end

  def small_create_button(url)
    fa_icon_link_to 'Create', 'plus', url, class: 'btn btn-default btn-xs'
  end

  def small_add_button(url, options = {})
    fa_icon_link_to 'Add', 'plus', url, options.reverse_merge(class: 'btn btn-default btn-xs')
  end

  def events_button(url)
    fa_icon_link_to 'Events', 'newspaper-o', url, class: 'btn btn-default'
  end

  def assessments_button(url)
    link_to 'Assessments', url, class: 'btn btn-default'
  end

  def attachments_button(url)
    fa_icon_link_to 'Attachments', 'paperclip', url, class: 'btn btn-default'
  end

end