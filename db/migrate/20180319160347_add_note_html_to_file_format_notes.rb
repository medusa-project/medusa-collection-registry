class AddNoteHtmlToFileFormatNotes < ActiveRecord::Migration[5.1]
  def change
    add_column :file_format_notes, :note_html, :text
  end
end
