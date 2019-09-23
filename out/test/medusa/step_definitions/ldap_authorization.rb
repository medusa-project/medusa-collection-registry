When(/^I edit repository administration groups$/) do
  visit edit_ldap_admins_repositories_path
end

And(/^I fill in ldap administration info '([^']*)' for the repository titled '([^']*)'$/) do |domain_and_group, title|
  domain, group = domain_and_group.split('\\')
  within_form_for(title) do
    fill_in('repository[ldap_admin_group]', with: group)
    #select(domain, from: 'repository[ldap_admin_domain]')
  end
end

And(/^in the ldap administration form for the repository titled '([^']*)' I click on '([^']*)'$/) do |title, label|
  within_form_for(title) do
    click_on(label)
  end
end

Then(/^the repository titled '([^']*)' should be administered by the group '([^']*)' in the domain '([^']*)'$/) do |title, group, domain|
  repository = Repository.where(title: title).first
  expect(repository.ldap_admin_domain).to eq(domain)
  expect(repository.ldap_admin_group).to eq(group)
end

def within_form_for(title)
  within find(:xpath, "//a[text()='#{title}']/ancestor::form") do
    yield
  end
end