class Item < ActiveRecord::Base
  belongs_to :project, touch: true
end
