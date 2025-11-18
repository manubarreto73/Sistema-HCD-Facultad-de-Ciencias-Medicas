class ExpedientsController < ApplicationController
  before_action :set_expedient, only: %i[edit show update destroy]
  PER_PAGE = 3
  def index
    @tab = params[:tab] || 'no_tratados'
    @expedients =
      if @tab == 'tratados'
        Expedient.treated
      elsif @tab == 'no_tratados'
        Expedient.no_treated
      else
        Expedient.all
      end
  end

  def new
    @expedient = Expedient.new
    render layout: false
  end

  def show
    @expedient = Expedient.find(params[:id])
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @expedient = Expedient.new(expedient_params)

    if @expedient.save
      @expedients = Expedient.all

      respond_to do |format|
        flash[:notice] = 'Expediente creado correctamente'
        format.turbo_stream
        format.html { redirect_to expedients_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_create }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @expedient.update(expedient_params)
      respond_to do |format|
        flash[:notice] = 'Expediente actualizado correctamente'
        format.turbo_stream
        format.html { redirect_to expedients_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expedient.deleted!

    @expedients = Expedient.all
    flash.now[:info] = "Expediente eliminado correctamente"

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expedients_path(page: @current_page), status: :see_other }
    end
  end

  private

  def set_expedient
    @expedient = Expedient.find(params[:id])
  end

  def expedient_params
    params.require(:expedient).permit(:file_number, :responsible, :detail, :opinion, :creation_date,:destination_id, :subject_id )
  end
end
