When /^I go to the repository creation page$/ do
  visit new_repository_path
end

When /^I go to the repository index page$/ do
  visit repositories_path
end

When /^I view the repository titled '(.*)'$/ do |title|
  visit repository_path(Repository.find_by_title(title))
end

When /^I edit the repository titled '(.*)'$/ do |title|
  visit edit_repository_path(Repository.find_by_title(title))
end
