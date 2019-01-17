#This is a dirty, imprecise way to dump some html for validation. We can probably do better, but
# this is okay for a start.

require 'singleton'
require 'set'

class HtmlDumper
  include Singleton

  attr_accessor :dump_number, :seen
  cattr_accessor :active
  attr_accessor :dump_number, :seen

  def initialize()
    FileUtils.rm_rf(dump_dir)
    FileUtils.mkdir_p(dump_dir)
    self.dump_number = 0
    self.seen = Set.new
  end

  def activate
    self.class.active = true
  end

  def dump_dir
    @dump_dir ||= File.join(Rails.root, 'tmp', 'html_dump')
  end

  def dump(page)
    return unless self.class.active
    if page.present? and page.html.start_with?('<!DOCTYPE html>')
      md5 = Digest::MD5.hexdigest(page.html)
      return if self.seen.include?(md5)
      self.seen << md5
      self.dump_number += 1
      target_file = File.join(dump_dir, "#{dump_number}.html")
      FileUtils.mkdir_p(File.dirname(target_file))
      File.open(target_file, 'wb') {|f| f.puts page.html}
      File.open(File.join(dump_dir, 'manifest'), 'a') {|f| f.puts "#{dump_number}: #{page.current_url}"}
    end
  end

end
