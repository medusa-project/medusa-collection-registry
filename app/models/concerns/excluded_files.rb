require 'active_support/concern'

module ExcludedFiles
  extend ActiveSupport::Concern

  def excluded_files
    @excluded_files ||= Settings.classes.concerns.excluded_files.to_set
  end

  def excluded_directories
    @excluded_directories ||= Settings.classes.concerns.excluded_directories.to_set
  end

  def excluded_file?(filename)
    excluded_files.include?(filename)
  end

  def excluded_directory?(directory_name)
    excluded_directories.include?(directory_name)
  end

end