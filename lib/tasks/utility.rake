namespace :utility do
  desc 'Nudge accrual job to assessing after external copying and key removal'
  task :nudgejob, [:ingest_id] => [:environment] do |t, args|
    wf = Workflow::AccrualJob.find_by(id: args[:ingest_id])
    puts "no workflow accrual job found" unless wf
    next unless wf
    wf.perform_await_copy_messages
  end
  desc 'Remove CaptureOne directories'
  task :remove_capture_one, [:author_email] => [:environment] do |t, args|
    cfs_directories = CfsDirectory.where(path: 'CaptureOne')
    groups = Set.new
    collections = Set.new
    paths = Set.new

    cfs_directories.each do |dir|
      groups.add(dir.file_group)
      collections.add(dir.collection)
      paths.add(dir.relative_path)
    end
    File.open('//tmp/paths.txt', 'w') do |f|
      paths.each { |path| f << "#{path}\n" }
    end
    File.open('//tmp/groups.txt', 'w') do |f|
      groups.each { |group| f << "#{group.id.to_s}\n" }
    end
    File.open('//tmp/collections.txt', 'w') do |f|
      collections.each { |collection| f << "#{collection.id.to_s}\n" }
    end
    # remove CaptureOne directories and any files in them
    cfs_directories.each do |dir|
      files = storage_files
      files.each do |file|
        file_key = File.join(dir.key, file)
        dir.storage_root.delete_content(file_key) if storage_root.exist?(file_key)
      end
      dir.storage_root.delete_content(dir.key) if storage_root.exist?(dir.key)
    end

    # re-assess containing collections
    collections.each do |col|
      assessment = Assessment.create(assessable_id: col.id,
                                  date: Time.now,
                                  notes: "",
                                  preservation_risks: "",
                                  assessable_type: 'Collection',
                                  name: "removed CaptureOne",
                                  preservation_risk_level: 'low',
                                  assessment_type: 'external_files',
                                  naming_conventions: "",
                                  storage_medium_id: nil,
                                  directory_structure: "",
                                  last_access_date: nil,
                                  file_format: "",
                                  total_file_size: nil,
                                  total_files: nil,
                                  author_email: args[:author_email])
    end
  end
end