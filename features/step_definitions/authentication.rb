Given /^I am logged in as '(.*)'$/ do |uid|
  login_user(:uid => uid)
end

#Given /^I am logged in$/ do
#  login_user
#end

Given(/^I am logged in as a medusa admin$/) do
  login_user(:uid => 'admin')
end

Given /^I am logged in as a visitor$/ do
  login_user(:uid => 'visitor')
end

Given /^I am logged in as an admin$/ do
  login_user(:uid => 'admin')
end

Given /^I am logged in as a manager$/ do
  login_user(:uid => 'manager')
end

Given /^I relogin as (.*)$/ do |login_type|
  step "I logout"
  step "I am logged in as #{login_type}"
end

Given /^I am not logged in$/ do
  #nothing - this is the default state
end

Then /^I should be on the login page$/ do
  current_path.should == '/auth/developer'
end

Given /^I logout$/ do
  visit '/logout'
end

private

def login_user(opts = {})
  user = User.find_by(:uid => opts[:uid]) || FactoryGirl.create(:user, opts)
  visit(login_path)
  fill_in('name', :with => user.uid)
  fill_in('email', :with => user.uid) #this is to accommodate the developer strategy, which uses the email as the UIN
  click_button('Sign In')
end