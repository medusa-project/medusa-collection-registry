class AddSummaryAndProvenanceNoteToFileGroups < ActiveRecord::Migration
  def change
    add_column :file_groups, :summary, :text
    add_column :file_groups, :provenance_note, :text
  end
end
