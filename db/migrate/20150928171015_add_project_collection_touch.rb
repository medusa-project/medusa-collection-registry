require 'simple_trigger_helper'

class AddProjectCollectionTouch < ActiveRecord::Migration
  def up
    trigger_helper.create_trigger
  end

  def down
    trigger_helper.drop_trigger
  end

  def trigger_helper
    SimpleTriggerHelper.new(source_table: 'projects', target_table: 'collections')
  end
end
