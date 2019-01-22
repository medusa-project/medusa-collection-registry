module SearchesHelper

  def search_indicator_icon(search_helper)
    if search_helper.full_count.positive?
      fa_icon('check', class: 'search-hit')
    else
      fa_icon('times', class: 'search-missed')
    end
  end

end