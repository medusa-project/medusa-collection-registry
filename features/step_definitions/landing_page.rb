And /^I should see introductory text about Medusa$/ do
  page.should have_selector('#landing-information')
end