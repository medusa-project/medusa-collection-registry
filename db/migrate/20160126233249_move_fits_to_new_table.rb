class MoveFitsToNewTable < ActiveRecord::Migration
  def up
    create_table :fits_results do |t|
      t.references :cfs_file, foreign_key: true
      t.text :xml
    end
    add_index :fits_results, :cfs_file_id, unique: true
    insert_sql = <<SQL
  INSERT INTO fits_results (cfs_file_id, xml)
    (SELECT id, fits_xml
     FROM cfs_files WHERE fits_xml IS NOT NULL)
SQL
    ActiveRecord::Base.connection.execute(insert_sql)
    remove_column :cfs_files, :fits_xml
  end

  def down
    add_column :cfs_files, :fits_xml, :text
    update_sql = <<SQL
  UPDATE cfs_files CF
  SET fits_xml = FR.xml
  FROM fits_results FR
  WHERE CF.id IN (SELECT cfs_file_id FROM FR)
  AND CF.id = FR.cfs_file_id
SQL
    ActiveRecord::Base.connection.execute(update_sql)
    drop_table :fits_results
  end
end
