class DestinationsController < ApplicationController
  before_action :set_destination, only: %i[edit update destroy]

  def index
    @destinations = Destination.actives
  end

  def new
    @destination = Destination.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @destination = Destination.new(destination_params)

    if @destination.save
      @destinations = Destination.actives

      respond_to do |format|
        flash[:notice] = 'Destino creado correctamente'
        format.turbo_stream
        format.html { redirect_to destinations_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_create }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @destination.update(destination_params)
      respond_to do |format|
        flash[:notice] = 'Destino actualizado correctamente'
        format.turbo_stream
        format.html { redirect_to destinations_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @destination.update(active: false)

    @destinations = Destination.actives
    flash.now[:info] = "Destino eliminado correctamente"

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to destinations_path(page: @current_page), status: :see_other }
    end
  end

  private

  def set_destination
    @destination = Destination.find(params[:id])
  end

  def destination_params
    params.require(:destination).permit(:name, :is_commission)
  end
end
