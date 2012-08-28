module ApplicationHelper
  def net_id_search_url(net_id)
    "http://illinois.edu/ds/search?skinId=0&search_type=userid&search=#{net_id}"
  end

  def net_id_search_link(net_id)
    if net_id.blank?
      ''
    else
      link_to net_id, net_id_search_url(net_id), :target => '_blank', :class => 'net-id-search'
    end
  end

  def net_id_search_links(net_ids)
    return '' if net_ids.blank?
    net_ids.split(',').collect do |net_id|
      net_id_search_link(net_id.strip)
    end.join(', ').html_safe
  end
end
