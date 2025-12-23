class ExpedientsController < ApplicationController
  before_action :set_expedient, only: %i[edit show update destroy treat_from_agenda delete_from_agenda mark_as_treated_modal modal_delete history delete_from_agenda_modal]

  def index
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    paginator = Paginator.new(@expedients.order(sort_order), page: params[:page])
    @expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
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

      paginator = Paginator.new(Expedient.order(:file_number), page: params[:page])
      @expedients = paginator.paginated
      @page = paginator.page
      @total_pages = paginator.total_pages
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

    flash.now[:info] = 'Expediente eliminado correctamente'
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call
    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count
    @expedients = params[:treated].to_s == 'true' ? @expedients.treated : @expedients.no_treated
    paginator = Paginator.new(@expedients.order(sort_order), page: @page)
    @expedients = paginator.paginated
    if @expedients.empty? && @page > 1
      @page -= 1
      paginator = Paginator.new(@expedients.order(sort_order), page: @page)
      @expedients = paginator.paginated
    end
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expedients_path }
    end
  end

  def download_pdf
    treated = params[:treated] == 'true'
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call

    @title = treated ? 'Historial' : 'Expedientes no resueltos'

    respond_to do |format|
      format.pdf do
        render pdf: @title.parameterize,
        template: 'expedients/expedients_pdf',
        layout: 'pdf',
        encoding: 'UTF-8',
        orientation: 'landscape',
        margin: { top: 20, bottom: 10, left: 5, right: 5 },
        header: {
          html: { template: 'expedients/pdf/header',
          layout: false }
        },
        footer: {
          html: { template: 'expedients/pdf/footer',
          layout: false,
          spacing: 5 }
        }
      end
    end
  end

  def treat_from_agenda
    @expedient.treated!
    @expedient.update(treat_date: Date.today)

    flash.now[:notice] = "Expediente #{@expedient.file_number} marcado como tratado."
    index_params = filter_params
    @daily_agenda = @expedient.daily_agenda
    @expedients = ExpedientsFilter.new(@daily_agenda.expedients.includes(:destination, :subject), index_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated.order(sort_order) : @expedients.no_treated.order(sort_order)
    paginator = Paginator.new(@expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def delete_from_agenda
    position = @expedient.position
    daily_agenda = @expedient.daily_agenda

    @expedient.update!(daily_agenda_id: nil, position: nil)
    daily_agenda.reorder_positions_from!(position)

    current_page = params[:page].to_i
    current_page = 1 if current_page < 1

    total_expedients = daily_agenda.expedients.count
    paginator = Paginator.new(Expedient.order(:file_number), page: params[:page])
    per_page = paginator.per_page

    total_pages = (total_expedients / per_page.to_f).ceil
    total_pages = 1 if total_pages.zero?

    current_page = total_pages if current_page > total_pages

    flash[:notice] = "Expediente #{@expedient.file_number} eliminado de la orden del día."

    if daily_agenda.hcd?
      redirect_to today_daily_agendas_path(page: current_page)
    else
      redirect_to destination_daily_agenda_path(
        destination_id: daily_agenda.destination_id,
        page: current_page
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
    index_params = filter_params
    @expedients = Expedient.deleted.includes(:expedient_histories)
    @expedients = ExpedientsFilter.new(@expedients, index_params).call

    paginator = Paginator.new(@expedients.order(sort_order), page: params[:page])
    @expedients = paginator.paginated.map(&:deleted_info) # map *después* de la query
    @page = paginator.page
    @total_pages = paginator.total_pages
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
    p = params.require(:expedient).permit(:dependency, :file_digits, :file_year, :correspondence, :responsible, :detail, :opinion, :creation_date,:destination_id, :subject_id)
    p[:file_number] = "#{p.delete(:dependency)}-#{p.delete(:file_digits)}/#{p.delete(:file_year)}-#{p.delete(:correspondence)}"

    p
  end

  def filter_params
    params.permit(:file_number, :subject_id, :destination_id, :from_date, :to_date, :treated, :sort, :direction, :page)
  end

  def sort_order
    column = params[:sort].presence || 'file_number'
    direction = params[:direction].presence || 'asc'
    "#{column} #{direction}"
  end
end
