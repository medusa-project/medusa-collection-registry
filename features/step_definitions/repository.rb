Then /^A repository with title '(.*)' should exist$/ do |repository_title|
  Repository.find_by_title(repository_title).should_not be_nil
end
