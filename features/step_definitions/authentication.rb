Given /^I am logged in as '([^']*)'$/ do |uid|
  login_user(uid: uid)
end

Given /^I am logged in as an? (.*)$/ do |type|
  login_user(uid: "#{type}@example.com")
end

Given /^I relogin as (.*)$/ do |login_type|
  step 'I logout'
  step "I am logged in as #{login_type}"
end

Given /^I am not logged in$/ do
  visit '/logout'
end

Then /^I should be on the login page$/ do
  current_path.should == '/auth/identity'
end

Given /^I logout$/ do
  visit '/logout'
end

Given(/^I provide basic authentication$/) do
  page.driver.browser.authorize 'machine_user', 'machine_password'
end

private

def login_user(opts = {})
  opts[:email] ||= opts[:uid] if opts[:uid]
  user = User.find_by(uid: opts[:uid]) || FactoryBot.create(:user, opts)

  identity = Identity.find_or_create_by(name: user.email, email: user.email)
  salt = BCrypt::Engine.generate_salt
  encrypted_password = BCrypt::Engine.hash_secret(user.email, salt)
  identity.password_digest = encrypted_password
  identity.update(password: user.email, password_confirmation: user.email)
  identity.save!

  visit(login_path)
  fill_in('auth_key', with: user.email)
  fill_in('password', with: user.email) #this is to accommodate the identity strategy
  click_button('Connect')
end