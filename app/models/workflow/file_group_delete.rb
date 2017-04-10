require 'fileutils'
class Workflow::FileGroupDelete < Workflow::Base

  belongs_to :file_group
  belongs_to :requester, class_name: 'User'
  belongs_to :approver, class_name: 'User'

  before_create :cache_fields

  STATES = %w(start email_superusers wait_decision email_requester_accept email_requester_reject move_content delete_content restore_content email_restored_content email_requester_final_removal end)
  validates_inclusion_of :state, in: STATES, allow_blank: false

  def perform_start
    be_in_state_and_requeue('email_superusers')
  end

  def perform_email_superusers
    Workflow::FileGroupDeleteMailer.email_superusers(self).deliver_now
    be_in_state('wait_decision')
  end

  def perform_wait_decision
    unrunnable_state
  end

  def perform_email_requester_accept
    Workflow::FileGroupDeleteMailer.requester_accept(self).deliver_now
    be_in_state_and_requeue('move_content')
  end

  def perform_email_requester_reject
    Workflow::FileGroupDeleteMailer.requester_reject(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_move_content
    create_db_backup_tables
    move_physical_content
    destroy_db_objects
    be_in_state_and_requeue('delete_content', run_at: Time.now + 120.days)
  end

  def perform_delete_content
    delete_db_backup_tables
    FileUtils.rm_rf(holding_directory_path)
    delete_amazon_backups
    collection = Collection.find_by(id: cached_collection_id)
    Event.create!(eventable: collection, key: :file_group_delete_final, actor_email: requester.email,
                  note: "File Group #{file_group_id} - #{cached_file_group_title} | Collection: #{cached_collection_id}") if collection.present?
    e = Event.all.to_a
    be_in_state_and_requeue('email_requester_final_removal')
  end

  def perform_restore_content
    restore_physical_content
    restore_db_content
    be_in_state_and_requeue('email_restored_content')
  end

  def perform_email_requester_final_removal
    Workflow::FileGroupDeleteMailer.requester_final_removal(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_email_restored_content
    Workflow::FileGroupDeleteMailer.restored_content(self).deliver_now
    be_in_state_and_requeue('end')
  end

  def perform_end
    destroy_queued_jobs_and_self
  end

  def approver_email
    approver.present? ? approver.email : 'Unknown'
  end

  def restore_content_requested
    destroy_queued_jobs
    be_in_state_and_requeue('restore_content')
  end

  def cache_fields
    self.cached_file_group_title ||= file_group.title
    self.cached_collection_id ||= file_group.collection_id
    self.cached_cfs_directory_id ||= file_group.cfs_directory_id
  end

  protected

  def move_physical_content
    FileUtils.mkdir_p(Settings.medusa.cfs.fg_delete_holding)
    FileUtils.move(file_group.cfs_directory.absolute_path, holding_directory_path)
  end

  def restore_physical_content
    restore_path = File.join(CfsRoot.instance.path, cached_collection_id.to_s, file_group_id.to_s)
    unless Dir.exist?(restore_path)
      FileUtils.mkdir_p(File.join(CfsRoot.instance.path, cached_collection_id.to_s))
      FileUtils.move(holding_directory_path, restore_path)
    end
  end

  def holding_directory_path
    File.join(Settings.medusa.cfs.fg_delete_holding, file_group_id.to_s)
  end


  def destroy_db_objects
    file_group.cfs_directory.destroy_tree_from_leaves
    transaction do
      file_group.destroy!
      Event.create!(eventable: file_group.collection, key: :file_group_delete_moved, actor_email: requester.email,
                    note: "File Group #{file_group.id} - #{file_group.title} | Collection: #{file_group.collection.id}")
    end
  end

  def db_backup_schema_name
    "fg_holding_#{file_group_id}"
  end

  def db_backup_schema_exists?
    ActiveRecord::Base.connection.table_exists? "#{db_backup_schema_name}.file_groups"
  end

  #This is the big one
  #First we check to see if we've already done this step. To do this just look for a table in the right schema,
  #e.g. db_backup_schema_name.file_groups
  #If that is not found, then create and run the SQL to do a huge transaction that will:
  #- Save file group info to db_backup_schema_name.file_groups - just select based on id
  #- Save cfs directory info to db_backup_schema_name.cfs_directories - use root cfs dir id to get all of them
  #- Save cfs file info to db_backup_schema_name.cfs_files - all that belong to the above dirs
  #- Save rights declaration to db_backup_schema_name.rights_declaration - select based on file group id
  #- Save assessments to db_backup_schema_name.assessments - select based on file group id
  #- Save event info to db_backup_schema_name.events - three selects, one for each of the file group, dirs, and files
  # these will be create table via selects except for two of the events which will be insert into table via selects
  def create_db_backup_tables
    return if db_backup_schema_exists?
    transaction do
      ActiveRecord::Base.connection.execute(create_db_backup_tables_sql)
    end
  end

  def delete_db_backup_tables
    ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{db_backup_schema_name} CASCADE")
  end

  def create_db_backup_tables_sql
    root_cfs_directory_id = file_group.cfs_directory.id
    <<SQL
CREATE SCHEMA #{db_backup_schema_name};
CREATE TABLE #{db_backup_schema_name}.file_groups AS 
  SELECT * FROM file_groups WHERE id=#{file_group_id};
CREATE TABLE #{db_backup_schema_name}.cfs_directories AS 
  SELECT * FROM cfs_directories WHERE root_cfs_directory_id=#{root_cfs_directory_id};
CREATE TABLE #{db_backup_schema_name}.cfs_files AS
  SELECT * FROM cfs_files WHERE cfs_directory_id IN (SELECT id FROM #{db_backup_schema_name}.cfs_directories);
CREATE TABLE #{db_backup_schema_name}.rights_declarations AS
  SELECT * FROM rights_declarations WHERE rights_declarable_id=#{file_group_id} AND rights_declarable_type='FileGroup';
CREATE TABLE #{db_backup_schema_name}.assessments AS
  SELECT * FROM assessments WHERE assessable_id=#{file_group_id} AND assessable_type='FileGroup';
CREATE TABLE #{db_backup_schema_name}.events AS
  SELECT * FROM events WHERE eventable_id=#{file_group_id} AND eventable_type='FileGroup';
INSERT INTO #{db_backup_schema_name}.events
  SELECT * FROM events WHERE eventable_id IN (SELECT id FROM #{db_backup_schema_name}.cfs_directories)
                        AND eventable_type='CfsDirectory';
INSERT INTO #{db_backup_schema_name}.events
  SELECT * FROM events WHERE eventable_id IN (SELECT id FROM #{db_backup_schema_name}.cfs_files)
                        AND eventable_type='CfsFile';
SQL
  end

  def restore_db_content
    return unless db_backup_schema_exists?
    transaction do
      ActiveRecord::Base.connection.execute(restore_db_backup_tables_sql)
    end
    file_group.after_restore
    AmazonBackup.create_and_schedule(requester, file_group.cfs_directory)
    Event.create!(eventable: file_group.collection, key: :file_group_delete_restored, actor_email: requester.email,
                  note: "File Group #{file_group.id} - #{file_group.title} | Collection: #{file_group.collection.id}")
  end

  def restore_db_backup_tables_sql
    <<SQL
    INSERT INTO file_groups SELECT * FROM #{db_backup_schema_name}.file_groups;
    INSERT INTO cfs_directories SELECT * FROM #{db_backup_schema_name}.cfs_directories;
    UPDATE #{db_backup_schema_name}.cfs_files SET fits_serialized = 'f';
    INSERT INTO cfs_files SELECT * FROM #{db_backup_schema_name}.cfs_files;
    INSERT INTO rights_declarations SELECT * FROM #{db_backup_schema_name}.rights_declarations;
    INSERT INTO assessments SELECT * FROM #{db_backup_schema_name}.assessments;
    INSERT INTO events SELECT * FROM #{db_backup_schema_name}.events;
    DROP SCHEMA IF EXISTS #{db_backup_schema_name} CASCADE;
SQL
  end

  def delete_amazon_backups
    AmazonBackup.where(cfs_directory_id: cached_cfs_directory_id).each do |amazon_backup|
      amazon_backup.delete_archives_and_self
    end
  end

end
