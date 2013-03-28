class CfsController < ApplicationController

  def show
    @path = params[:path] || ''
    file_system_path = cfs_file_path(@path)
    if File.directory?(file_system_path)
      setup_directory(file_system_path)
      render 'show_directory'
    elsif File.exists?(file_system_path)
      setup_file(file_system_path)
      render 'show_file'
    else
      render 'show_not_found'
    end
  end

  def fits_info
    raise RuntimeError
  end

  def create_fits_info
    ensure_fits_xml(params[:path])
    redirect_to cfs_show_path(remove_path_level(path))
  end

  protected

  def ensure_fits_xml(path)
    Cfs.ensure_fits_for(path)
  end

  def cfs_file_path(url_path)
    File.join(Cfs.instance.root, url_path)
  end

  def setup_file(path)
    setup_breadcrumbs(@path)
    setup_file_group(@path)
  end

  def setup_directory(path)
    setup_breadcrumbs(@path)
    setup_file_group(@path)
    @subdirectories = []
    @files = []
    (Dir[File.join(path, '*')] + Dir[File.join(path, '.*')]).each do |entry|
      name = File.basename(entry)
      next if ['.', '..'].include?(name)
      link_data = {:name => name, :path => path_join(@path, name)}
      if File.directory?(entry)
        @subdirectories << link_data
      else
        @files << link_data.merge(:stat => File.stat(entry))
      end
    end
  end

  def setup_breadcrumbs(path)
    components = path.split('/')
    components.pop #discard last component
    @breadcrumbs = [['/', '']].tap do |accumulator|
      components.each do |component|
        accumulator.push [component, path_join(accumulator.last.last, component)]
      end
    end
  end

  def path_join(prefix, suffix)
    prefix.blank? ? suffix : "#{prefix}/#{suffix}"
  end

  #I don't know an efficient way to do this, as the paths we have here will generally
  #be longer than the cfs_roots of file groups.
  def setup_file_group(path)
    @file_group = FileGroup.for_cfs_path(path)
  end

  def remove_path_level(path)
    return path if path.blank?
    components = path.split('/')
    components.pop
    return components.join('/')
  end

end