And /^I should see a link to the wiki in the body$/ do
  within 'body' do
    page.should have_link('digital preservation wiki', href: wiki_url)
  end
end

Then /^I should see a link to the wiki in the navbar$/ do
  within '#global-navigation' do
    page.should have_link('Wiki', href: wiki_url)
  end
end

def wiki_url
  'https://wiki.cites.uiuc.edu/wiki/display/LibraryDigitalPreservation/Home'
end
