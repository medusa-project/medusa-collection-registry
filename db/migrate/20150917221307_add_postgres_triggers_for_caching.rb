#Definitely Postgres specific
#The trigger defs are written out for maximum clarity as to what is happening in each case.
#The updating algorithm is the standard diffing one, but naturally relies on everything being consistent when
#the triggers are installed. So that should be checked! I'll provide some sql queries/views to help with that, in
#fact before I merge this in.
class AddPostgresTriggersForCaching < ActiveRecord::Migration

  def up
    drop_all_triggers
    define_all_trigger_functions
    create_all_triggers
    update_bit_level_file_group_stats
  end

  def down
    drop_all_triggers
  end

  FUNCTION_TO_TABLE_MAP = {'cfs_file_update_cfs_directory_and_extension_and_content_type' => 'cfs_files',
                           'cfs_dir_update_cfs_dir' => 'cfs_directories',
                           'cfs_dir_update_bit_level_file_group' => 'cfs_directories'}

  def update_bit_level_file_group_stats
    BitLevelFileGroup.find_each do |fg|
      if cfs_directory = fg.cfs_directory
        fg.total_files = cfs_directory.tree_count
        fg.total_file_size = cfs_directory.tree_size / 1.gigabtye
        fg.save!
      end
    end
  end

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

  def define_all_trigger_functions
    FUNCTION_TO_TABLE_MAP.keys.each do |function|
      ActiveRecord::Base.connection.execute(send("#{function}_function_sql"))
    end
  end

  #When a CFS file is updated then it needs to update its owning directory
  #Note that we need to work around the fact that size is allowed to be null for cfs_files
  def cfs_file_update_cfs_directory_and_extension_and_content_type_function_sql
    <<SQL
CREATE OR REPLACE FUNCTION cfs_file_update_cfs_directory_and_extension_and_content_type() RETURNS trigger AS $$
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      UPDATE cfs_directories
      SET tree_count = tree_count + 1,
          tree_size = tree_size + COALESCE(NEW.size, 0)
      WHERE id = NEW.cfs_directory_id;
      UPDATE content_types
      SET cfs_file_count = cfs_file_count + 1,
          cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
      WHERE id = NEW.content_type_id;
      UPDATE file_extensions
      SET cfs_file_count = cfs_file_count + 1,
          cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
      WHERE id = NEW.file_extension_id;
    ELSIF (TG_OP = 'UPDATE') THEN
      IF (NEW.cfs_directory_id = OLD.cfs_directory_id) THEN
        IF (COALESCE(NEW.size,0) != COALESCE(OLD.size,0)) THEN
          UPDATE cfs_directories
          SET tree_size = tree_size + (COALESCE(NEW.size,0) - COALESCE(OLD.size,0))
          WHERE id = NEW.cfs_directory_id;
        END IF;
      ELSE
        UPDATE cfs_directories
        SET tree_count = tree_count + 1,
            tree_size = tree_size + COALESCE(NEW.size, 0)
        WHERE id = NEW.cfs_directory_id;
        UPDATE cfs_directories
        SET tree_count = tree_count - 1,
            tree_size = tree_size - COALESCE(OLD.size, 0)
        WHERE id = OLD.cfs_directory_id;
      END IF;
      IF (NEW.content_type_id = OLD.content_type_id) THEN
        IF (COALESCE(NEW.size,0) != COALESCE(OLD.size,0)) THEN
          UPDATE content_types
          SET cfs_file_size = cfs_file_size + (COALESCE(NEW.size,0) - COALESCE(OLD.size,0))
          WHERE id = NEW.content_type_id;
        END IF;
      ELSE
        UPDATE content_types
        SET cfs_file_count = cfs_file_count + 1,
            cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
        WHERE id = NEW.content_type_id;
        UPDATE content_types
        SET cfs_file_count = cfs_file_count - 1,
            cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
        WHERE id = OLD.content_type_id;
      END IF;
      IF (NEW.file_extension_id = OLD.file_extension_id) THEN
        IF (COALESCE(NEW.size,0) != COALESCE(OLD.size,0)) THEN
          UPDATE file_extensions
          SET cfs_file_size = cfs_file_size + (COALESCE(NEW.size,0) - COALESCE(OLD.size,0))
          WHERE id = NEW.cfs_directory_id;
        END IF;
      ELSE
        UPDATE file_extensions
        SET cfs_file_count = cfs_file_count + 1,
            cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
        WHERE id = NEW.file_extension_id;
        UPDATE file_extensions
        SET cfs_file_count = cfs_file_count - 1,
            cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
        WHERE id = OLD.file_extension_id;
      END IF;
    ELSIF (TG_OP = 'DELETE') THEN
      UPDATE cfs_directories
      SET tree_count = tree_count - 1,
          tree_size = tree_size - COALESCE(OLD.size,0)
      WHERE id = OLD.cfs_directory_id;
      UPDATE content_types
      SET cfs_file_count = cfs_file_count - 1,
          cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
      WHERE id = OLD.content_type_id;
      UPDATE file_extensions
      SET cfs_file_count = cfs_file_count - 1,
          cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
      WHERE id = OLD.file_extension_id;
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;
SQL
  end

  #When a non-root CfsDirectory is updated it needs to update its owning directory
  def cfs_dir_update_cfs_dir_function_sql
    <<SQL
CREATE OR REPLACE FUNCTION cfs_dir_update_cfs_dir() RETURNS trigger AS $$
  BEGIN
    IF (TG_OP = 'INSERT' AND NEW.parent_type = 'CfsDirectory') THEN
      UPDATE cfs_directories
      SET tree_count = tree_count + NEW.tree_count,
          tree_size = tree_size + NEW.tree_size
      WHERE id = NEW.parent_id;
    ELSIF (TG_OP = 'UPDATE' AND NEW.parent_type = 'CfsDirectory') THEN
      IF ((NEW.tree_size != OLD.tree_size) OR NEW.tree_count != OLD.tree_count) THEN
        UPDATE cfs_directories
        SET tree_size = tree_size + (NEW.tree_size - OLD.tree_size),
            tree_count = tree_count + (NEW.tree_count - OLD.tree_count)
        WHERE id = NEW.parent_id;
      END IF;
    ELSIF (TG_OP = 'DELETE' AND OLD.parent_type = 'CfsDirectory') THEN
      UPDATE cfs_directories
      SET tree_count = tree_count - OLD.tree_count,
          tree_size = tree_size - OLD.tree_size
      WHERE id = OLD.parent_id;
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;
SQL
  end

  #When a root CfsDirectory is updated it needs to update its corresponding bit level file group
  #Recall we need to convert the size to gigabytes
  def cfs_dir_update_bit_level_file_group_function_sql
    <<SQL
CREATE OR REPLACE FUNCTION cfs_dir_update_bit_level_file_group() RETURNS trigger AS $$
  BEGIN
    IF ((TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.parent_type = 'FileGroup')  THEN
      UPDATE file_groups
      SET total_files = NEW.tree_count,
          total_file_size = NEW.tree_size / 1073741824
      WHERE id = NEW.parent_id;
    ELSIF (TG_OP = 'DELETE' AND OLD.parent_type = 'FileGroup') THEN
      UPDATE file_groups
      SET tree_count = 0,
          tree_size = 0
      WHERE id = OLD.parent_id;
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;
SQL
  end

end
