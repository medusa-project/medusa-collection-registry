Then /^I should be redirected to the unauthorized page$/ do
  current_path.should == unauthorized_path
end