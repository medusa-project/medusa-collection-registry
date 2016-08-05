class FileFormatDecorator < BaseDecorator

  def pronom_link
    h.link_to(object.pronom_id, pronom_url)
  end

  def pronom_url
    "http://www.nationalarchives.gov.uk/PRONOM/#{object.pronom_id}"
  end

end