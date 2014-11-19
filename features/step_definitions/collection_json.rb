When /^I request JSON for the collection titled '(.*)'$/ do |title|
  visit collection_path(Collection.find_by_title(title), format: 'json')
end