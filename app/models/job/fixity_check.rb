require 'tempfile'

class Job::FixityCheck < ApplicationRecord
  belongs_to :user
  belongs_to :fixity_checkable, polymorphic: true
  belongs_to :cfs_directory

  validates :user, presence: true
  validates :cfs_directory, presence: true
  validates_uniqueness_of :fixity_checkable_id, scope: :fixity_checkable_type

  def self.create_for(fixity_checkable, cfs_directory, user)
    Delayed::Job.enqueue(self.create!(fixity_checkable: fixity_checkable, cfs_directory: cfs_directory, user: user), priority: 50)
  end

  def perform
    create_manifest
    generate_results_file
    results = generate_results_hash
    interpret_results_hash(results)
    self.fixity_checkable.events.create!(key: 'fixity_check_completed', date: Date.today, actor_email: user.email)
    delete_manifest_and_results_files
  end

  def delete_manifest_and_results_files
    File.delete(self.manifest_file_path) if File.exist?(self.manifest_file_path)
    File.delete(self.result_file_path) if File.exist?(self.result_file_path)
  end

  def interpret_results_hash(results)
    self.cfs_directory.each_file_in_tree do |cfs_file|
      case results[cfs_file.relative_path]
        when 'OK'
          cfs_file.update_fixity_status_ok
        when 'FAILED'
          cfs_file.update_fixity_status_bad_with_event(actor_email: self.user.email)
        when 'NOT_FOUND'
          cfs_file.update_fixity_status_not_found_with_event(actor_email: self.user.email)
        else
          raise RuntimeError, "Unexpected result for fixity check job. Cfs File Id: #{cfs_file.id}"
      end
    end
  end

  def generate_results_hash
    Hash.new.tap do |hash|
      File.open(self.result_file_path) do |result_file|
        result_file.each_line do |line|
          path, result = line.split(/:\s+/)
          clean_path = path.sub(/^(\.\/)?/, '')
          hash[clean_path] = result.chomp
        end
      end
    end
  end

  def generate_results_file
    Dir.chdir(CfsRoot.instance.path) do
      system "md5sum -c #{self.manifest_file_path} > #{self.result_file_path}"
    end
  end

  def create_manifest
    File.open(self.manifest_file_path, 'w') do |manifest|
      self.cfs_directory.each_file_in_tree do |cfs_file|
        manifest.puts("#{cfs_file.md5_sum}  #{cfs_file.relative_path}") if cfs_file.md5_sum.present?
      end
    end
  end

  def manifest_file_path
    File.join(CfsRoot.instance.tmp_path, "fixity_check_expected_#{self.id}.md5")
  end

  def result_file_path
    File.join(CfsRoot.instance.tmp_path, "fixity_check_results_#{self.id}.txt")
  end

end
