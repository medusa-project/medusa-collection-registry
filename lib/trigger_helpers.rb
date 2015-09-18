module TriggerHelpers

  def simple_touch_function_name(source_table, association)
    "#{source_table}_touch_#{association}"
  end

  def simple_touch_trigger_name(source_table, association)
    "#{simple_touch_function_name(source_table, association)}_trigger"
  end

  def drop_simple_touch_trigger_sql(source_table, association)
    <<SQL
    DROP TRIGGER IF EXISTS #{simple_touch_trigger_name(source_table, association)} ON #{source_table};
SQL
  end

  def drop_simple_touch_trigger(source_table, association)
    ActiveRecord::Base.connection.execute(drop_simple_touch_trigger_sql(source_table, association))
  end

  def create_simple_touch_trigger_sql(source_table, association)
    <<SQL
    CREATE TRIGGER #{simple_touch_trigger_name(source_table, association)}
    AFTER INSERT OR UPDATE OR DELETE ON #{source_table}
    FOR EACH ROW
    EXECUTE PROCEDURE #{simple_touch_function_name(source_table, association)}();
SQL
  end

  def create_simple_touch_trigger(source_table, association)
    ActiveRecord::Base.connection.execute(create_simple_touch_trigger_sql(source_table, association))
  end

  def create_simple_touch_trigger_function_sql(source_table, association, target_table)
    <<SQL
    CREATE OR REPLACE FUNCTION #{simple_touch_function_name(source_table, association)}() RETURNS trigger AS $$
    BEGIN
      IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        UPDATE #{target_table}
        SET updated_at = NEW.updated_at
        WHERE id = NEW.#{association}_id;
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE #{target_table}
        SET updated_at = localtimestamp
        WHERE id = OLD.#{association}_id;
      END IF;
      RETURN NULL;
    END;
$$ LANGUAGE plpgsql;
SQL
  end

  def create_simple_touch_trigger_function(source_table, association, target_table)
    ActiveRecord::Base.connection.execute(create_simple_touch_trigger_function_sql(source_table, association, target_table))
  end

  def drop_simple_touch_trigger_function_sql(source_table, association)
    <<SQL
  DROP FUNCTION IF EXISTS #{simple_touch_trigger_name(source_table, association)}();
SQL
  end


  def drop_simple_touch_trigger_function(source_table, association)
    ActiveRecord::Base.connection.execute(drop_simple_touch_trigger_function_sql(source_table, association))
  end

end