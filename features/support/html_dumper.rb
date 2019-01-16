#This is a dirty, imprecise way to dump some html for validation. We can probably do better, but
# this is okay for a start.

require 'singleton'

class HtmlDumper
  include Singleton

  attr_accessor :dump_number
  #I'm not sure why this doesn't work properly if this is on the instance side, but it doesn't. So put
  # it on the class side
  cattr_accessor :active

  def initialize()
    FileUtils.rm_rf(dump_dir)
    FileUtils.mkdir_p(dump_dir)
    self.dump_number = 0
  end

  def activate
    self.class.active = true
  end

  def dump_dir
    @dump_dir ||= File.join(Rails.root, 'tmp', 'html_dump')
  end

  def dump(page)
    x = self.class.active
    return unless self.class.active
    if page.present? and page.html.start_with?('<!DOCTYPE html>')
      self.dump_number += 1
      target_file = File.join(dump_dir, "#{dump_number}.html")
      FileUtils.mkdir_p(File.dirname(target_file))
      File.open(target_file, 'wb') {|f| f.puts page.html}
      File.open(File.join(dump_dir, 'manifest'), 'a') {|f| f.puts "#{dump_number}: #{page.current_url}"}
    end
  end

end