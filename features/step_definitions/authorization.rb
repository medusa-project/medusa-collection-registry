Then /^I should be redirected to the unauthorized page$/ do
  current_path.should == unauthorized_path
end

Then /^I should be unauthorized$/ do
  step ('I should be redirected to the unauthorized page')
  step ("I should see 'You are not authorized to view the requested page.'")
end

#The following needs to drop down into Rack::Test - this is because we want to test authorization for things
#like an update action (PUT) which is not easily done with capybara. We'll try to make this pretty general
#so that it can test a lot of things, even though that will complicate this method and its helpers.
#Note that this is only really intended for testing things which should fail before anything really happens -
#to test something that you expect to work you can use the normal Capybara stuff. (E.g. we may test an update with
#this - if we're not authorized then we should get bounced before it matters whether we pass query parameters,
# so we don't. This makes this not useful for doing something you expect to work.)
#Similarly, something like a simple get of an index should be testable via Capybara directly; it's really
#the new and create actions on the collection level that may be problematic.

Then /^trying to (.*) the (.*) with (.*) '(.*)' as (.*) should (.*)$/ do |action, resource_type, unique_field, field_value, user_type, result|
  underscored_resource_type = resource_type.gsub(' ', '_')
  resource_class = Kernel.const_get(underscored_resource_type.camelcase)
  resource = resource_class.where(unique_field => field_value).first
  perform_action(action, user_type, resource)
  check_result(result)
end

Then /^trying to do (.*) with the (.*) collection as (.*) should (.*)$/ do |action, resource_type, user_type, result|
  underscored_resource_type = resource_type.gsub(' ', '_')
  resource_class = Kernel.const_get(underscored_resource_type.camelcase)
  perform_action(action, user_type, resource_class.new)
  check_result(result)
end

Then(/^deny object permission on the (.*) with (.*) '(.*)' to users for action with redirection:$/) do |resource_type, unique_field, field_value, table|
  with_user_action_result_table(table) do |user_type, action, redirection_type|
    step "trying to #{action.strip} the #{resource_type} with #{unique_field} '#{field_value}' as a #{user_type.strip} should redirect to #{redirection_type}"
  end
end

Then /^trying to do (.*) with the path '(.*)' as (.*) should (.*)$/ do |action, path_function, user_type, result|
  rack_login(user_type)
  self.send(action, self.send(path_function))
  check_result(result)
end

And(/^deny permission on the (.*) collection to users for action with redirection:$/) do |resource_type, table|
  table.raw.each do |user_types, actions, redirection_type|
    user_types.split(',').each do |user_type|
      actions.split(',').each do |action|
        step "trying to do #{action.strip} with the #{resource_type} collection as a #{user_type.strip} should redirect to #{redirection_type}"
      end
    end
  end
end

def with_user_action_result_table(table)
  table.raw.each do |user_types, actions, redirection_type|
    user_types.split(',').each do |user_type|
      actions.split(',').each do |raw_action|
        action = if raw_action.match(/(.*)\((.*)\)/)
          "#{$1} via #{$2}"
        else
          raw_action
        end
        yield user_type, action, redirection_type
      end
    end
  end
end

def perform_action(action, user_type, resource = nil)
  rack_login(user_type)
  base_path_method_name = "#{resource.class.to_s.underscore}_path"
  verb, url = case action.to_sym
    when :update
      [:put, self.send(base_path_method_name, resource)]
    when :delete, :destroy
      [:delete, self.send(base_path_method_name, resource)]
    when :edit
      [:get, self.send("edit_#{base_path_method_name}", resource)]
    when :new
      [:get, self.send("new_#{base_path_method_name}")]
    when :create
      [:post, self.send("#{resource.class.to_s.underscore.pluralize}_path")]
    when :view
      [:get, self.send(base_path_method_name, resource)]
    when :view_index
      [:get, self.send("#{resource.class.to_s.underscore.pluralize}_path")]
    else
      method, act = parse_action(action)
      if resource.new_record?
        [method, self.send("#{act}_#{resource.class.to_s.underscore}s_path")]
      else
        [method, self.send("#{act}_#{base_path_method_name}", resource)]
      end
  end
  self.send(verb, url)

end

def parse_action(action)
  if action.match(/^(.*) via (.*)$/)
    return $2, $1
  else
    return :get, action
  end
end

def rack_login(user_type)
  case user_type
    when 'a public user'
      post '/logout'
    when 'a visitor'
      post '/auth/developer/callback', {name: 'visitor@example.com', email: 'visitor@example.com'}
    when 'a manager'
      post '/auth/developer/callback', {name: 'manager@example.com', email: 'manager@example.com'}
    when /ldap user (.*)/
      post '/auth/developer/callback', {name: $1, email: $1}
    else
      raise 'Unexpected user type'
  end
end

def check_result(expected_result)
  case expected_result
    when 'redirect to authentication'
      expect(last_response.redirect?).to be_truthy
      expect(last_response.location).to match(/#{login_path}$/)
    when 'redirect to unauthorized'
      expect(last_response.redirect?).to be_truthy
      expect(last_response.location).to match(/#{unauthorized_path}$/)
    when 'succeed'
      expect(last_response.ok?).to be_truthy
    else
      raise 'Unexpected result type'
  end
end