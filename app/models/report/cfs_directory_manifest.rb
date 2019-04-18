require 'csv'
class Report::CfsDirectoryManifest

  attr_accessor :root_cfs_directory, :tsv

  HEADERS = ["Path", "Index", "Name", "Extension", "MIME", "Date Created", "Time Created", "Size Bytes", "UUID"]

  def initialize(cfs_directory)
    self.root_cfs_directory = cfs_directory
  end

  def generate_tsv(io)
    self.tsv = initialize_tsv(io)
    add_headers
    directory_stack = [root_cfs_directory]
    while current_directory = directory_stack.pop
      add_directory_to_tsv(current_directory)
      directory_stack.push(*current_directory.subdirectories.order(:path).reverse)
      current_directory.cfs_files.reset
      current_directory.subdirectories.reset
    end
  end

  def add_directory_to_tsv(cfs_directory)
    current_path = cfs_directory.relative_path + '/'
    self.tsv << directory_row(current_path, cfs_directory.uuid)
    index = 0
    cfs_directory.subdirectories.order(:path).includes(:medusa_uuid).each do |subdirectory|
      index += 1
      add_subdirectory_to_tsv(current_path, subdirectory, index)
    end
    cfs_directory.cfs_files.order(:name).includes(:file_extension, :content_type, :medusa_uuid).each do |cfs_file|
      index += 1
      add_cfs_file_to_tsv(current_path, cfs_file, index)
    end
    self.tsv << blank_line
  end

  def directory_row(current_path, uuid)
    @directory_row_padding ||= (HEADERS.length - 2).times.collect {''}
    [current_path, *@directory_row_padding, uuid]
  end

  def add_headers
    self.tsv << HEADERS
    self.tsv << breadcrumbs
    self.tsv << blank_line
  end

  def add_subdirectory_to_tsv(current_path, cfs_directory, index)
    self.tsv << [current_path, index, cfs_directory.path + '/', '', '',
                 to_date(cfs_directory), to_time(cfs_directory),
                 '', cfs_directory.uuid].collect!(&:to_s)
  end

  def add_cfs_file_to_tsv(current_path, cfs_file, index)
    self.tsv << [current_path, index, cfs_file.name, cfs_file.file_extension.extension,
                 cfs_file.content_type.name, to_date(cfs_file), to_time(cfs_file),
                 cfs_file.size, cfs_file.uuid].collect(&:to_s)
  end

  def initialize_tsv(io)
    self.tsv = CSV.new(io, col_sep: "\t")
  end

  def breadcrumbs
    breadcrumbs = "Printed from #{root_cfs_directory.parent.breadcrumbs.collect(&:breadcrumb_label).join(' > ')}"
    pad(breadcrumbs)
  end

  def blank_line
    @blank_line ||= pad(Array.new)
  end

  def pad(array_or_object)
    array = Array.wrap(array_or_object)
    padding = (HEADERS.length - array.length).times.collect {''}
    array + padding
  end

  #TODO may need to adjust these for localtime?
  def to_date(object)
    object.created_at.localtime.to_date.to_s
  end

  def to_time(object)
    object.created_at.localtime.strftime('%H:%M:%S')
  end

end