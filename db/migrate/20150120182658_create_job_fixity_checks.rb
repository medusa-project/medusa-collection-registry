class CreateJobFixityChecks < ActiveRecord::Migration
  def change
    create_table :job_fixity_checks do |t|
      t.references :user, index: true
      t.references :fixity_checkable, polymorphic: true
      t.references :cfs_directory, index: true
      t.timestamps null: false
    end
    add_foreign_key :job_fixity_checks, :users
    add_index :job_fixity_checks, [:fixity_checkable_id, :fixity_checkable_type], unique: 'true', name: 'fixity_object'
  end
end
