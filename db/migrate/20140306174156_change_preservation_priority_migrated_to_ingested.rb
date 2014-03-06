class ChangePreservationPriorityMigratedToIngested < ActiveRecord::Migration
  def up
    priority = PreservationPriority.where(:name => 'migrated').first
    priority.update_attribute(:name, 'ingested') if priority.present?
  end

  def down
    PreservationPriority.where(:name => 'ingested')
    priority.update_attribute(:name, 'migrated') if priority.present?
  end
end
