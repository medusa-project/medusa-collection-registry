module TriggerHelpers

  def install_simple_touch(source_table, target_table)

  end

  def uninstall_simple_touch(source_table, target_table)

  end

  def simple_touch_function_name(source_table, target_table)
    "#{source_table}_touch_#{target_table}"
  end

  def simple_touch_trigger_name(source_table, target_table)
    "#{simple_touch_function_name(source_table, target_table)}_trigger"
  end

  def drop_simple_touch_trigger_sql(source_table, target_table)
    <<SQL
    DROP TRIGGER IF EXISTS #{simple_touch_trigger_name(source_table, target_table)} ON #{source_table};
SQL
  end

  def drop_simple_touch_trigger(source_table, target_table)
    ActiveRecord::Base.connection.execute(drop_simple_touch_trigger_sql(source_table, target_table))
  end

  def create_simple_touch_trigger_sql(source_table, target_table)
    <<SQL
    CREATE TRIGGER #{simple_touch_trigger_name(source_table, target_table)}
    AFTER INSERT OR UPDATE OR DELETE ON #{source_table}
    FOR EACH ROW
    EXECUTE PROCEDURE #{simple_touch_function_name(source_table, target_table)}();
SQL
  end

  def create_simple_touch_trigger(source_table, target_table)
    ActiveRecord::Base.connection.execute(create_simple_touch_trigger_sql(source_table, target_table))
  end

  def create_simple_touch_trigger_function_sql(source_table, target_table)
    <<SQL
    CREATE OR REPLACE FUNCTION #{simple_touch_function_name(source_table, target_table)}() RETURNS trigger AS $$
    BEGIN
      IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        UPDATE #{target_table}
        SET updated_at = NEW.updated_at
        WHERE id = NEW.#{target_table.to_s.singularize}_id;
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE #{target_table}
        SET updated_at = localtimestamp
        WHERE id = OLD.#{target_table.to_s.singularize}_id;
      END IF;
      RETURN NULL;
    END;
$$ LANGUAGE plpgsql;
SQL
  end

  def create_simple_touch_trigger_function(source_table, target_table)
    ActiveRecord::Base.connection.execute(create_simple_touch_trigger_function_sql(source_table, target_table))
  end

  def drop_simple_touch_trigger_function_sql(source_table, target_table)
    <<SQL
  DROP FUNCTION IF EXISTS #{simple_touch_trigger_name(source_table, target_table)}();
SQL
  end


  def drop_simple_touch_trigger_function(source_table, target_table)
    ActiveRecord::Base.connection.execute(drop_simple_touch_trigger_function_sql(source_table, target_table))
  end

end