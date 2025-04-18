Then /^I should see all producer fields$/ do
  ['Address 1', 'Address 2', 'City', 'State', 'Zip', 'Phone Number', 'Email', 'URL', 'Notes'].each do |field|
    step "I should see '#{field}'"
  end
end

And /^The collection titled '([^']*)' has (\d+) file groups? produced by '([^']*)'$/ do |collection, count, producer|
  collection = Collection.find_by(title: collection)
  producer = Producer.find_by(title: producer)
  count.to_i.times do
    FactoryBot.create(:file_group, collection: collection, producer: producer)
  end
end


Given(/^there is a producer report job for user '(.*)' and the producer with title '(.*)'$/) do |user_email, producer_title|
  user = User.find_or_create_by(uid: user_email, email: user_email)
  producer = Producer.find_by(title: producer_title)
  Job::Report::Producer.create_for(user: user, producer: producer)
end

When(/^I perform producer report jobs$/) do
  Job::Report::Producer.all.each do |j|
    j.perform
  end
end