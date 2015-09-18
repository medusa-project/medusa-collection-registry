#Definitely Postgres specific
#The trigger defs are written out for maximum clarity as to what is happening in each case.
#The updating algorithm is the standard diffing one, but naturally relies on everything being consistent when
#the triggers are installed. So that should be checked! I'll provide some sql queries/views to help with that, in
#fact before I merge this in.
class AddPostgresTriggersForFileSizeAndCountCaching < ActiveRecord::Migration
  def up
    drop_all_triggers
    define_helper_functions
    define_all_trigger_functions
    create_all_triggers
  end

  def down
    drop_all_triggers
  end

  FUNCTION_TO_TABLE_MAP = {'cfs_file_update_cfs_directory' => 'cfs_files',
                           'cfs_dir_update_cfs_dir' => 'cfs_directories',
                           'cfs_dir_update_bit_level_file_group' => 'cfs_directories'}

  def trigger_name(function_name)
    function_name + '_trigger'
  end

  def drop_trigger_sql(function_name, table)
    <<SQL
DROP TRIGGER IF EXISTS #{trigger_name(function_name)} ON #{table};
SQL
  end

  def drop_all_triggers
    FUNCTION_TO_TABLE_MAP.each do |function, table|
      ActiveRecord::Base.connection.execute(drop_trigger_sql(function, table))
    end
  end

  def create_trigger_sql(function_name, table)
    <<SQL
CREATE TRIGGER #{trigger_name(function_name)}
AFTER INSERT OR UPDATE OR DELETE ON #{table}
FOR EACH ROW
EXECUTE PROCEDURE #{function_name}();
SQL
  end

  def create_all_triggers
    FUNCTION_TO_TABLE_MAP.each do |function, table|
      ActiveRecord::Base.connection.execute(create_trigger_sql(function, table))
    end
  end

  def define_helper_functions
    define_directory_count_helper
    define_directory_size_helper
  end

  def define_directory_count_helper
    sql = <<SQL
CREATE OR REPLACE FUNCTION cfs_directory_count_helper(directory_id INT) RETURNS INT AS $$
  BEGIN
    RETURN (SELECT COUNT(*) FROM cfs_files WHERE cfs_directory_id = directory_id) +
           (SELECT SUM(COALESCE(tree_count,0)) FROM cfs_directories WHERE parent_id = directory_id AND parent_type = 'CfsDirectory');
  END;
$$ LANGUAGE plpgsql
SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  def define_directory_size_helper
    sql = <<SQL
CREATE OR REPLACE FUNCTION cfs_directory_size_helper(directory_id INT) RETURNS NUMERIC AS $$
  BEGIN
    RETURN (SELECT SUM(COALESCE(size, 0)) FROM cfs_files WHERE cfs_directory_id = directory_id) +
           (SELECT SUM(COALESCE(tree_size,0)) FROM cfs_directories WHERE parent_id = directory_id AND parent_type = 'CfsDirectory');
  END;
$$ LANGUAGE plpgsql

SQL
    ActiveRecore::Base.connection.execute(sql)
  end

  def define_all_trigger_functions
    FUNCTION_TO_TABLE_MAP.keys.each do |function|
      ActiveRecord::Base.connection.execute(call("#{function}_function_sql"))
    end
  end

  def cfs_file_update_cfs_directory_function_sql
    <<SQL
CREATE OR REPLACE FUNCTION cfs_file_update_cfs_directory RETURNS trigger AS $$
  DECLARE
    owner_id int;
    old_owner_id int;
    new_owner_id int;
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      owner_id = NEW.cfs_directory_id;
      UPDATE cfs_directories
      SET tree_count = cfs_directory_count_helper(owner_id),
          tree_size = cfs_directory_size_helper(owner_id)
      WHERE id = owner_id;
    ELSIF (TG_OP = 'UPDATE') THEN
      old_owner_id = OLD.cfs_directory_id;
      new_owner_id = NEW.cfs_directory_id;
      UPDATE cfs_directories
      SET tree_count = cfs_directory_count_helper(new_owner_id),
          tree_size = cfs_directory_size_helper(new_owner_id)
      WHERE id = new_owner_id;
      IF (old_owner_id != new_owner_id) THEN
        UPDATE cfs_directories
        SET tree_count = cfs_directory_count_helper(old_owner_id),
            tree_size = cfs_directory_size_helper(old_owner_id)
        WHERE id = old_owner_id;
      END IF;
    ELSE
      owner_id = OLD.cfs_directory_id;
      UPDATE cfs_directories
      SET tree_count = cfs_directory_count_helper(owner_id),
          tree_size = cfs_directory_size_helper(owner_id)
    END IF;
    RETURN NULL;
  END;
$$
SQL
  end

  def cfs_dir_update_cfs_dir_function_sql
    <<SQL

SQL
  end

  def cfs_dir_update_bit_level_file_group_sql
    <<SQL

SQL
  end

end
