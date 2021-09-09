class ItemDecorator < BaseDecorator

  delegate :item_information_separator, to: :class

  def search_barcode_link
    h.link_to(self.barcode.if_blank('<no barcode>'), h.item_path(self))
  end

  def search_project_link
    h.link_to(self.project_title, h.project_path(self.project))
  end

  def search_batch_link
    if self.batch.present?
      h.link_to(self.batch, h.project_path(self.project, batch: self.batch))
    else
      ''
    end
  end

  def search_ebook_status
    return self.ebook_status if self.ebook_status.present?

    ''
  end

  def search_requester_info
    return self.requester_info if self.requester_info.present?

    ''
  end

  def search_external_link
    return self.external_link if self.external_link.present?

    ''
  end

  def search_reviewed_by
    return self.reviewed_by if self.reviewed_by.present?

    ''
  end

  #TODO: create the checkbox - disable unless user can actually use
  def assign_checkbox(project)
    h.check_box_tag('', self.id, false, name: 'mass_action[item][]', id: "mass_action_item_#{self.id}",
                    class: 'mass-item-checkbox', disabled: false)
  end

  #TODO: create the buttons
  def action_buttons
    h.content_tag(:span, class: 'project-items-table-actions') do
      h.small_edit_button(self) + h.small_clone_button(h.new_item_path(source_id: self.id), method: :get)
    end
  end

  def self.item_information_separator
    '|$^'
  end


  def item_information
    full_info_string = full_item_information
    truncated_info_string = truncated_item_information
    truncated_info_string = full_info_string.first(35) if truncated_info_string.blank?
    return "#{truncated_info_string}#{item_information_separator}#{full_info_string}"
  end

  INFO_FIELDS = %i(title author imprint item_title series sub_series box folder creator source_media date)
  def full_item_information
    INFO_FIELDS.collect do |field|
      object.send(field)
    end.reject do |value|
      value.blank?
    end.join('; ')
  end

  def truncated_item_information
    [object.title.try(:first, 30), object.date.try(:first, 4)].reject{|s| s.blank?}.join('-')
  end

end