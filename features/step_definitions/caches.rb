When /^I refresh file stat caches$/ do
  DbCacheUpdater.update_content_type_cache
  DbCacheUpdater.update_file_extension_cache
end