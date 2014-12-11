module PublicHelper
  def public_breadcrumbs(public_object)
    breadcrumbs = public_object.breadcrumbs
    links = breadcrumbs.collect do |breadcrumb|
      path = public_path(breadcrumb) rescue nil
      path ? link_to(breadcrumb.breadcrumb_label, path) : breadcrumb.breadcrumb_label
    end
    links.join(' > ').html_safe
  end

end