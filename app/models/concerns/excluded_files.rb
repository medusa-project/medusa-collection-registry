require 'active_support/concern'

module ExcludedFiles
  extend ActiveSupport::Concern

  def excluded_files
    @excluded_files ||= Settings.classes.concerns.excluded_files.to_set
  end

  def excluded_file?(filename)
    excluded_files.include?(filename)
  end

end