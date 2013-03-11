class Event < ActiveRecord::Base
  attr_accessible :eventable, :message, :note, :user_id
  belongs_to :eventable, :polymorphic => true
  belongs_to :user
end
