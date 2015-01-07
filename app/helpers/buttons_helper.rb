#some helpers for producing links/buttons
module ButtonsHelper

  def edit_button(url, options = {})
    url = edit_polymorphic_path(url) if url.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', 'pencil-square-o', url, options.merge(class: 'btn btn-default')
  end

  def small_edit_button(url, options = {})
    url = edit_polymorphic_path(url) if url.is_a?(ActiveRecord::Base)
    fa_icon_link_to 'Edit', 'pencil-square-o', url, options.merge(class: 'btn btn-default btn-xs')
  end

  def delete_button(url, message: nil, options: {})
    message ||= generic_confirm_message
    fa_icon_link_to 'Delete', 'trash-o', url, options.merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger')
  end

  def small_delete_button(url, message: nil, options: {})
    message ||= generic_confirm_message
    fa_icon_link_to 'Delete', 'trash-o', url, options.merge(method: :delete, data: {confirm: message}, class: 'btn btn-danger btn-xs')
  end

  def index_button(url)
    link_to 'Index', url, class: 'btn btn-default'
  end

  def small_view_button(url)
    link_to 'View', url, class: 'btn btn-default btn-xs'
  end

  def small_download_button(url)
    link_to 'Download', url, class: 'btn btn-default btn-xs'
  end

  def small_update_button(url)
    link_to 'Update', url, class: 'btn btn-default btn-xs'
  end

  def red_flags_button(url)
    fa_icon_link_to 'Red Flags', 'flag', url, class: 'btn btn-default'
  end

  def back_button(url)
    link_to 'Back', url, class: 'btn btn-default'
  end

end