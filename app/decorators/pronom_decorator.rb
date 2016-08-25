class PronomDecorator < BaseDecorator

  def link
    h.link_to(link_text, url)
  end

  def url
    "http://www.nationalarchives.gov.uk/PRONOM/#{pronom_id}"
  end

  def link_text
    version_text = "(#{version})" if version.present?
    link_text = [pronom_id, version_text].join(' ').strip
  end

end