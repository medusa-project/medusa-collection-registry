class SimpleTriggerHelper < Object

  attr_accessor :source_table, :association, :target_table

  def initialize(args = {})
    self.source_table = args[:source_table].to_s
    self.target_table = args[:target_table].to_s
    self.association = args[:association] || self.target_table.singularize
  end

  def create_trigger
    drop_trigger
    create_touch_trigger_function
    create_touch_trigger
  end

  def drop_trigger
    drop_touch_trigger
    drop_touch_trigger_function
  end

  protected

  def touch_function_name
    "#{source_table}_touch_#{association}"
  end

  def touch_trigger_name
    "#{touch_function_name}_trigger"
  end

  def drop_touch_trigger_sql
    <<SQL
    DROP TRIGGER IF EXISTS #{touch_trigger_name} ON #{source_table};
SQL
  end

  def drop_touch_trigger
    ActiveRecord::Base.connection.execute(drop_touch_trigger_sql)
  end

  def create_touch_trigger_sql
    <<SQL
    CREATE TRIGGER #{touch_trigger_name}
    AFTER INSERT OR UPDATE OR DELETE ON #{source_table}
    FOR EACH ROW
    EXECUTE PROCEDURE #{touch_function_name}();
SQL
  end

  def create_touch_trigger
    ActiveRecord::Base.connection.execute(create_touch_trigger_sql)
  end

  def create_touch_trigger_function_sql
    <<SQL
    CREATE OR REPLACE FUNCTION #{touch_function_name}() RETURNS trigger AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE #{target_table}
        SET updated_at = NEW.updated_at
        WHERE id = NEW.#{association}_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE #{target_table}
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.#{association}_id OR id = OLD.#{association}_id);
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

  def create_touch_trigger_function
    ActiveRecord::Base.connection.execute(create_touch_trigger_function_sql)
  end

  def drop_touch_trigger_function_sql
    <<SQL
  DROP FUNCTION IF EXISTS #{touch_function_name}();
SQL
  end

  def drop_touch_trigger_function
    ActiveRecord::Base.connection.execute(drop_touch_trigger_function_sql)
  end

end