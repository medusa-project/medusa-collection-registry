namespace :utility do
  desc 'Nudge accrual job to assessing after external copying and key removal'
  task :nudgejob, [:ingest_id] => [:environment] do |t, args|
    wf = Workflow::AccrualJob.find_by(id: args[:ingest_id])
    puts "no workflow accrual job found" unless wf
    next unless wf
    wf.perform_await_copy_messages
  end
  desc 'Remove CaptureOne directories'
  task :remove_capture_one => :environment do
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
      paths.each { |path| f << "#{path}/n" }
    end
    File.open('//tmp/groups.txt', 'w') do |f|
      groups.each { |group| f << "#{group}/n" }
    end
    File.open('//tmp/collections.txt', 'w') do |f|
      collections.each { |collection| f << "#{collection}/n" }
    end
    # TODO remove CaptureOne directories
    # TODO re-assess collections
  end
end