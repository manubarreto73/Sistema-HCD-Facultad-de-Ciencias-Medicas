class ExpedientsController < ApplicationController
  before_action :set_expedient, only: %i[edit show update destroy treat delete_from_agenda]
  PER_PAGE = 3

  def index
    index_params = filter_params
    @expedients = ExpedientsFilter.new(index_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated.order(sort_order) : @expedients.no_treated.order(sort_order)
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

  def treat
    @expedient.treated!
    flash.now[:notice] = "Expediente #{@expedient.file_number} marcado como tratado."

    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def delete_from_agenda
    @expedient.update(daily_agenda_id: nil)
    flash.now[:notice] = "Expediente #{@expedient.file_number} eliminado de la orden del día."

    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def download_pdf
    treated = params[:treated] == 'true'
    @expedients = Expedient.where(treated: treated)
    title = treated ? 'Expedientes tratados' : 'Expedientes no tratados'
    respond_to do |format|
      format.pdf do
        render pdf: title, template: 'expedients/expedients_pdf'
      end
    end
  end

  private

  def set_expedient
    @expedient = Expedient.find(params[:id])
  end

  def expedient_params
    p = params.require(:expedient).permit(:dependency, :file_digits, :file_year, :correspondence, :responsible, :detail, :opinion, :creation_date,:destination_id, :subject_id)
    p[:file_number] = "#{p.delete(:dependency)}-#{p.delete(:file_digits)}/#{p.delete(:file_year)}-#{p.delete(:correspondence)}"

    p
  end

  def filter_params
    params.permit(:file_number, :subject_id, :destination_id, :from_date, :to_date, :treated, :sort, :direction)
  end

  def sort_order
    column = params[:sort].presence || 'file_number'
    direction = params[:direction].presence || 'asc'
    "#{column} #{direction}"
  end
end
