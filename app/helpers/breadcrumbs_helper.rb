module BreadcrumbsHelper

  def breadcrumbs(object)
    breadcrumbs = object.breadcrumbs
    links = breadcrumbs.collect do |breadcrumb|
      link_to(breadcrumb.breadcrumb_label, breadcrumb)
    end
    links.join(' > ').html_safe
  end

end