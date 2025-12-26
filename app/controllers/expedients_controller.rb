class ExpedientsController < ApplicationController
  EXPEDIENTS_PARAMS = %i[dependency file_digits file_year correspondence responsible detail opinion creation_date destination_id subject_id].freeze
  FILTER_PARAMS = %i[file_number subject_id destination_id from_date to_date treated sort direction page].freeze
  before_action :set_expedient,
                only: %i[edit show update destroy delete_from_agenda mark_as_treated_modal modal_delete history
                         delete_from_agenda_modal]
  def index
    @treated_count = Expedient.treated.count
    @no_treated_count = Expedient.no_treated.count
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call
    paginate
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
      @expedient.create_history(current_user)
      paginate
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
      @expedient.modify_history(current_user)
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
    @expedient.logic_delete(current_user)
    @page = params[:page].to_i
    @treated_count = Expedient.treated.count
    @no_treated_count = Expedient.no_treated.count
    flash.now[:info] = 'Expediente eliminado correctamente'
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call
    paginate
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expedients_path }
    end
  end

  def download_pdf
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call
    @title = params[:treated] == 'true' ? 'Historial' : 'Expedientes no resueltos'
    respond_to do |format|
      format.pdf do
        render pdf: @title.parameterize,
               template: 'expedients/expedients_pdf',
               layout: 'pdf',
               encoding: 'UTF-8',
               orientation: 'landscape',
               margin: { top: 20, bottom: 10, left: 5, right: 5 },
               header: { html: { template: 'expedients/pdf/header', layout: false } },
               footer: { html: { template: 'expedients/pdf/footer', layout: false, spacing: 5 } }
      end
    end
  end

  def delete_from_agenda
    position = @expedient.position
    daily_agenda = @expedient.daily_agenda
    @expedient.update!(daily_agenda_id: nil, position: nil)
    paginate_agenda(daily_agenda, position)
    flash[:notice] = "Expediente #{@expedient.file_number} eliminado de la orden del día."

    if daily_agenda.hcd?
      redirect_to today_daily_agendas_path(page: @page)
    else
      redirect_to destination_daily_agenda_path(
        destination_id: daily_agenda.destination_id,
        page: @page
      )
    end
  end

  def modal_delete
    @page = params[:page]
    render layout: false
  end

  def mark_as_treated_modal
    render layout: false
  end

  def history; end

  def deleted
    @expedients = Expedient.deleted.includes(:expedient_histories)
    @expedients = ExpedientsFilter.new(@expedients, filter_params.merge(treated: 'deleted')).call

    paginate
  end

  def delete_from_agenda_modal
    @page = params[:page]
    render layout: false
  end

  private

  def set_expedient
    @expedient = Expedient.find(params[:id])
  end

  def expedient_params
    p = params.require(:expedient).permit(EXPEDIENTS_PARAMS)
    p[:file_number] =
      "#{p.delete(:dependency)}-#{p.delete(:file_digits)}/#{p.delete(:file_year)}-#{p.delete(:correspondence)}"

    p
  end

  def filter_params
    params.permit(FILTER_PARAMS)
  end

  def paginate
    @expedients ||= Expedient.order(:file_number)
    paginator = Paginator.new(@expedients.order(sort_order), page: params[:page])
    @expedients = paginator.paginated
    if @expedients.empty? && @page > 1
      @page -= 1
      paginator = Paginator.new(@expedients.order(sort_order), page: @page)
      @expedients = paginator.paginated
    end
    @page = paginator.page
    @total_pages = paginator.total_pages
  end

  def paginate_agenda(daily_agenda, position)
    daily_agenda.reorder_positions_from!(position)
    @expedients = daily_agenda.expedients
    paginate
  end


  def sort_order
    column = params[:sort].presence || 'file_number'
    direction = params[:direction].presence || 'asc'
    "#{column} #{direction}"
  end
end
