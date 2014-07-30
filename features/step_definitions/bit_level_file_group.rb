Given(/^The bit level file group statistics cache is up to date$/) do
  BitLevelFileGroup.update_cached_file_stats
end