require 'open3'

class VirusScan < ActiveRecord::Base
  #attr_accessible :file_group_id, :scan_result
  belongs_to :file_group

  def self.check_file_group(file_group)
    return unless file_group.cfs_root.present?
    scan_result = self.run_clam(Cfs.file_path_for(file_group.cfs_root))
    self.transaction do
      file_group.virus_scans.create(:scan_result => scan_result[:raw_result])
      scan_result[:hits].each do |hit|
        file_info = CfsFileInfo.find_or_create_by(path: hit[:path])
        file_info.red_flags.create(:message => "Virus Detected: #{hit[:message]}")
      end
    end
  end

  #We exclude "OK" files from what we return to save space - just return the FOUND files and the summary
  def self.run_clam(directory_path)
    output, status = Open3.capture2("clamscan -r #{directory_path} | grep -v 'OK$' | grep -v 'Empty file$'")
    return parse_clam_result(output)
  end

  #return two values, the list of files for which a problem is found and the summary
  def self.parse_clam_result(result)
    hits_section, summary_section = result.split(/\s*-+\s*SCAN SUMMARY\s*\-+\s*/)
    hits = hits_section.lines.collect do |line|
      fields = line.gsub(/ FOUND$/, '').partition(':')
      full_path = fields.first
      message = fields.last.strip
      Hash.new.tap do |h|
        h[:path] = Cfs.url_path_for(full_path)
        h[:message] = message
      end
    end
    summary = Hash.new.tap do |h|
      h[:clam_engine_version] = summary_section.match(/Engine version: (.*)$/)[1]
      h[:scanned_directory_count] = summary_section.match(/Scanned directories: (\d+)/)[1].to_i
      h[:scanned_file_count] = summary_section.match(/Scanned files: (\d+)/)[1].to_i
      h[:infected_file_count] = summary_section.match(/Infected files: (\d+)/)[1].to_i
      h[:scanned_data_size] = summary_section.match(/Data scanned: (.*)$/)[1]
      h[:time] = summary_section.match(/Time: (.*)$/)[1]
    end
    return {:hits => hits, :summary => summary, :raw_result => result}
  end

end
