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

  protected

  def cfs_file_path(url_path)
    File.join(MedusaRails3::Application.cfs_root, url_path)
  end

  def setup_file(path)
    setup_breadcrumbs(@path)
  end

  def setup_directory(path)
    setup_breadcrumbs(@path)
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
end