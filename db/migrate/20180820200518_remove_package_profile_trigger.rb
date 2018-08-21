class RemovePackageProfileTrigger < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute('DROP TRIGGER file_groups_touch_package_profile_trigger ON file_groups ;')
    ActiveRecord::Base.connection.execute('DROP FUNCTION public.file_groups_touch_package_profile ;')
  end
end
