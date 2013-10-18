class RelatedFileGroupJoin < ActiveRecord::Base
  #attr_accessible :source_file_group_id, :note, :target_file_group_id

  belongs_to :source_file_group, :class_name => 'FileGroup'
  belongs_to :target_file_group, :class_name => 'FileGroup'

end
