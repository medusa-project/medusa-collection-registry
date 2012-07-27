class ProductionUnitsController < ApplicationController

  before_filter :find_production_unit, :only => [:show, :destroy, :edit, :update]

  def index
    @production_units = ProductionUnit.all
  end

  def show

  end

  def destroy
    if @production_unit.destroy
      redirect_to production_units_path
    else
      redirect_to :back, :alert=> 'Production Units with associated file groups cannot be deleted.'
    end
  end

  def new
    @production_unit = ProductionUnit.new
  end

  def create
    @production_unit = ProductionUnit.new(params[:production_unit])
    if @production_unit.save
      redirect_to production_unit_path(@production_unit)
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    if @production_unit.update_attributes(params[:production_unit])
      redirect_to production_unit_path(@production_unit)
    else
      render 'edit'
    end

  end

  protected

  def find_production_unit
    @production_unit = ProductionUnit.find(params[:id])
  end
end
