#not fully aptly named, as this is just the items for the project. But close enough for now.
json.data do
  json.array! @items do |item|
    json.cache! item do
      row = Array.new.tap do |row|
        row << link_to(item.barcode.if_blank('<no barcode>'), item)
        row << item.bib_id
        row << item.some_title
        row << item.notes
        row << (link_to(item.batch, project_path(@project, batch: item.batch))).gsub('"', "'")
        row << check_box_tag('', item.id, false, name: 'assign_batch[assign][]', id: "assign_batch_assign_#{item.id}") if safe_can?(:update, @project)
        row << item.call_number
        row << item.author
        row << item.record_series_id
        row << small_edit_button(item) + ' ' + small_clone_button(new_item_path(source_id: item.id), method: :get)
      end
      json.array! row
    end
  end
end