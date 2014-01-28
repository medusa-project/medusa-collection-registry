Then /^I should be redirected to the unauthorized page$/ do
  current_path.should == unauthorized_path
end

Then /^I should be unauthorized$/ do
  step ("I should be redirected to the unauthorized page")
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


def perform_action(action, user_type, resource = nil)
  rack_login(user_type)
  base_path_method_name = "#{resource.class.to_s.underscore}_path"
  verb, url = case action.to_sym
    when :update
      [:put, self.send(base_path_method_name, resource)]
    when :delete
      [:delete, self.send(base_path_method_name, resource)]
    when :edit
      [:get, self.send("edit_#{base_path_method_name}", resource)]
    when :new
      [:get, self.send("new_#{base_path_method_name}")]
    when :create
      [:post, self.send("#{resource.class.to_s.underscore}s_path")]
    when :view
      [:get, self.send(base_path_method_name, resource)]
    else
      if resource.new_record?
        [:get, self.send("#{action}_#{resource.class.to_s.underscore}s_path")]
      else
        [:get, self.send("#{action}_#{base_path_method_name}", resource)]
      end
  end
  self.send(verb, url)

end

def rack_login(user_type)
  case user_type
    when 'a public user'
      #do nothing, not logged in
    when 'a visitor'
      post '/auth/developer/callback', {name: 'visitor', email: 'visitor'}
    when 'a manager'
      post '/auth/developer/callback', {name: 'manager', email: 'manager'}
    when /ldap user (.*)/
      post '/auth/developer/callback', {name: $1, email: $1}
    else
      raise "Unexpected user type"
  end
end

def check_result(expected_result)
  case expected_result
    when 'redirect to authentication'
      assert last_response.redirect?
      assert last_response.location.match(/#{login_path}$/)
    when 'redirect to unauthorized'
      assert last_response.redirect?
      assert last_response.location.match(/#{unauthorized_path}$/)
    when 'succeed'
      assert last_response.ok?
    else
      raise "Unexpected result type"
  end
end