class ResourceTypesController < ApplicationController

  def index
    @resource_types = ResourceType.all.order(:name)
  end

end