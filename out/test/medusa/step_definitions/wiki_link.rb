Then /^I should see a link to the wiki in the navbar$/ do
  within '#global-navigation' do
    page.should have_link('Wiki', href: wiki_url)
  end
end

def wiki_url
  'https://wiki.cites.uiuc.edu/wiki/display/LibraryDigitalPreservation/Home'
end
