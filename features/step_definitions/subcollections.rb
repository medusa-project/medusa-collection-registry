And(/^the collection titled '([^']*)' has a subcollection titled '([^']*)'$/) do |parent_title, child_title|
  parent = Collection.find_by(title: parent_title)
  child = Collection.find_by(title: child_title)
  parent.child_collections << child
end

Then(/^the collection titled '([^']*)' should have a subcollection titled '([^']*)'$/) do |parent_title, child_title|
  parent = Collection.find_by(title: parent_title)
  child = Collection.find_by(title: child_title)
  expect(parent.child_collections.include?(child)).to be_truthy
end

Then(/^the collection titled '([^']*)' should not have a subcollection titled '([^']*)'$/) do |parent_title, child_title|
  parent = Collection.find_by(title: parent_title)
  child = Collection.find_by(title: child_title)
  expect(parent.child_collections.include?(child)).to be_falsey
end