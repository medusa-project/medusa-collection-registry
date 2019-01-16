#This is a dirty, imprecise way to dump some html for validation. We can probably do better, but
# this is okay for a start.

require 'singleton'

class HtmlDumper
  include Singleton

  attr_accessor :dump_number, :active

  def initialize()
    FileUtils.rm_rf(dump_dir)
    FileUtils.mkdir_p(dump_dir)
    self.dump_number = 0
  end

  def activate
    self.active = true
  end

  def dump_dir
    @dump_dir ||= File.join(Rails.root, 'tmp', 'html_dump')
  end

  def dump(page)
    return unless self.active
    if page.present? and page.html.start_with?('<!DOCTYPE html>')
      self.dump_number += 1
      target_file = File.join(dump_dir, "#{dump_number}.html")
      FileUtils.mkdir_p(File.dirname(target_file))
      File.open(target_file, 'wb') {|f| f.puts page.html}
      File.open(File.join(dump_dir, 'manifest'), 'a') {|f| f.puts "#{dump_number}: #{page.current_url}"}
    end
  end

end