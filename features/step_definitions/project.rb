And(/^I fill in item mass edit fields:$/) do |table|
  table.raw.each do |label, value|
    field = label.gsub(' ', '_').underscore
    check "mass_action_allow_blank_#{field}"
    fill_in "mass_action_#{field}", with: value
  end
end