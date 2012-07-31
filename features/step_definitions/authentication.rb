Given /^I am logged in$/ do
  user = FactoryGirl.create(:user)
  visit(login_path)
  fill_in('name', :with => user.uid)
  fill_in('email', :with => "#{user.uid}@example.com" )
  click_button('Sign In')
end

Given /^I am not logged in$/ do
  #nothing - this is the default state
end

Then /^I should be on the login page$/ do
  current_path.should == '/auth/developer'
end