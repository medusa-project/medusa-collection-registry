And /^I should see the (.*) definition$/ do |term|
  page.should have_selector("##{term}-definition")
end