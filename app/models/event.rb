class Event < ActiveRecord::Base
  attr_accessible :eventable, :message, :note, :user
  belongs_to :eventable, :polymorphic => true
  belongs_to :user
end
