module DirectoriesHelper

  def directory_breadcrumbs(path, current)
    path.collect do |directory|
      name = directory.root? ? 'root' : directory.name
      directory == current ? name : link_to(name, directory_path(directory))
    end.reverse.join(' > ').html_safe
  end
end