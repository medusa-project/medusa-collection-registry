class EventsController < ApplicationController
  autocomplete :user, :uid
end