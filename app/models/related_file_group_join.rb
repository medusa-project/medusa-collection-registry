class RelatedFileGroupJoin < ActiveRecord::Base
  belongs_to :source_file_group, class_name: 'FileGroup', touch: true
  belongs_to :target_file_group, class_name: 'FileGroup', touch: true

end
