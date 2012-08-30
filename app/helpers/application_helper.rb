module ApplicationHelper
  def net_id_search_url(net_id)
    "http://illinois.edu/ds/search?skinId=0&search_type=userid&search=#{net_id}"
  end

  def net_id_search_link(net_id)
    if net_id.blank?
      ''
    else
      link_to_external net_id, net_id_search_url(net_id), :class => 'net-id-search'
    end
  end

  def net_id_search_links(net_ids)
    return '' if net_ids.blank?
    net_ids.split(',').collect do |net_id|
      net_id_search_link(net_id.strip)
    end.join(', ').html_safe
  end

  def link_to_external(name, url, opts = {})
    link_to name, url, opts.merge(:target => '_blank')
  end

  #standard way to render a value in a show view
  def show_value(value, label)
    render 'shared/show_value', :label => label, :value => value
  end

  #standard way to render a field of a model in a show view, with custom label if needed
  def show_field(model, field, label = nil)
    label ||= field.to_s.titlecase
    show_value(model.send(field), label)
  end
end
