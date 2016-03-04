Application.group_resolver = if Rails.env.production?
  GroupResolver::Ad.new
else
  GroupResolver::Test.new
end