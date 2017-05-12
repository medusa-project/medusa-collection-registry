require 'rake'
require 'csv'
require 'open3'

desc 'Output a CSV formatted version of "rake routes" to routes.csv'
task :routes_csv do
  raw_output, status = Open3.capture2('rake routes')
  lines = raw_output.each_line.to_a
  header = lines.shift.strip
  CSV.open('routes.csv', 'w') do |csv|
    csv << header.split(/\s+/)
    lines.each do |line|
      line.strip!
      fields = line.split(/\s+/, 4)
      while fields.count < 4
        fields.unshift('')
      end
      csv << fields
    end
  end
end