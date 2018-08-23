class RemovePreservationPriorityTrigger < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute('DROP TRIGGER collections_touch_preservation_priority_trigger ON collections ;')
    #ActiveRecord::Base.connection.execute('DROP FUNCTION collections_touch_preservation_priority ;')
  end
end
