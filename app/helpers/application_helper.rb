module ApplicationHelper
  def net_id_search_url(net_id)
    "http://illinois.edu/ds/search?skinId=0&search_type=userid&search=#{net_id}"
  end
end
