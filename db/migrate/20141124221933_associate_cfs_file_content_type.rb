#Move the CfsFile content_type string field to an associated ContentType object
#For the purposes of the migration we don't assume that the association between the two
#is defined yet - do the work without it.
#The renaming is to make things work if the association is already defined.
class AssociateCfsFileContentType < ActiveRecord::Migration
  def up
    add_column :cfs_files, :content_type_id, :integer
    rename_column :cfs_files, :content_type, :old_content_type
    #As you'd expect, this is slow. The SQL version is still better than doing it in Rails
    ContentType.connection.execute('INSERT INTO content_types(name) SELECT DISTINCT old_content_type FROM cfs_files')
    ContentType.connection.execute('UPDATE cfs_files SET content_type_id =
        (SELECT ct.id FROM content_types AS ct WHERE ct.name = cfs_files.old_content_type)')
    #If you need to do it in rails, here you go
    # CfsFile.find_each.with_index do |cfs_file, i|
    #   if cfs_file.old_content_type.present?
    #     content_type = ContentType.find_or_create_by(name: cfs_file.old_content_type)
    #     cfs_file.content_type_id = content_type.id
    #     cfs_file.save!
    #   end
    #   if i % 1000 == 0
    #     puts "Updated cfs file #{i} of #{count}"
    #   end
    # end
    add_index :cfs_files, :content_type_id
    remove_column :cfs_files, :old_content_type
  end

  def down
    add_column :cfs_files, :new_content_type, :string, index: true
    #As with the up migration, this could be written much faster with SQL, but I'm not going to do it unless
    #I actually need the down migration
    CfsFile.find_each.with_index do |cfs_file, i|
      if cfs_file.content_type_id.present?
        content_type = ContentType.find(cfs_file.content_type_id)
        cfs_file.new_content_type = content_type.name
        cfs_file.save!
      end
    end
    rename_column :cfs_files, :new_content_type, :content_type
    remove_column :cfs_files, :content_type_id
  end
end
