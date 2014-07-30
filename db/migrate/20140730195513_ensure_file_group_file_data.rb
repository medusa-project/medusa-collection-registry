class EnsureFileGroupFileData < ActiveRecord::Migration
  def up
    FileGroup.all.each do |file_group|
      file_group.total_files ||= 0
      file_group.total_file_size ||= 0
      file_group.save!
    end
  end

  def down
    #nothing
  end
end
