#some helpers for producing links/buttons
module ButtonsHelper

  def edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', 'pencil-square-o', url_or_object, options.merge(class: 'btn btn-default')
  end

  def small_edit_button(url_or_object, options = {})
    url_or_object = edit_polymorphic_path(url_or_object) if url_or_object.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', 'pencil-square-o', url_or_object, options.merge(class: 'btn btn-default btn-xs')
  end

  def delete_button(url_or_object, message: nil, options: {})
    message ||= generic_confirm_message
    fa_icon_link_to 'Delete', 'trash-o', url_or_object, options.merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger')
  end

  def small_delete_button(url_or_object, message: nil, options: {})
    message ||= generic_confirm_message
    fa_icon_link_to 'Delete', 'trash-o', url_or_object, options.merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger btn-xs')
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

end