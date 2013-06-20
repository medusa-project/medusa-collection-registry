class RedFlag < ActiveRecord::Base
  attr_accessible :message, :red_flaggable_id, :red_flaggable_type, :notes
  belongs_to :red_flaggable, :polymorphic => true
end
