class DailyAgendasController < ApplicationController
  before_action :set_daily_agenda, only: %i[edit update resolve show download_pdf mark_as_treated_modal mark_expedient_as_treated modal_list treat treat_destination edit_expedients update_expedients_order]

  before_action :set_destination, only: [:today, :treated]
  def treated
    @year  = params[:year]&.to_i || Date.today.year
    @month = params[:month]&.to_i || Date.today.month

    date = Date.new(@year, @month)

    @prev_month = (date - 1.month).month
    @prev_year  = (date - 1.month).year

    @next_month = (date + 1.month).month
    @next_year  = (date + 1.month).year

    @daily_agendas = DailyAgenda.where(date: date.beginning_of_month..date.end_of_month, destination: @destination).select(&:treated?).group_by(&:date)

    @days_agenda = build_calendar(date)
  end

  def treat
    @destinations = Destination.actives
  end

  def treat_destination
    params[:expedients].each do |expedient_id, data|
      e = Expedient.find(expedient_id)
      new_destination = Destination.find(data[:destination_id].to_i)
      if data[:file_status]
        e.update(file_status: 'treated')
      else
        e.update(daily_agenda_id: nil)
      end
      e.update(treat_date: Date.today)
      DailyAgendaExpedientHistory.create!(
        daily_agenda: @daily_agenda,
        expedient: e,
        previous_destination: e.destination,
        new_destination: new_destination
        )
      e.update(destination: new_destination)
      e.modify_history(current_user)
    end
    flash[:notice] = 'Orden de destino tratada'
    redirect_to destination_daily_agenda_path(destination_id: @daily_agenda.destination.id)
  end

  # 3176-89421933/9917-174
  # 8561-56138954/5926-450
  # 5052-80158179/1058-905

  def today
    
    @daily_agenda = DailyAgenda.next_daily_agenda(@destination)
    @daily_count = DailyAgenda.where(date: Date.today, destination: @destination).count
    index_params = filter_params
    @expedients = ExpedientsFilter.new(@daily_agenda.expedients.includes(:destination, :subject), index_params).call.ordered
    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated.order(sort_order) : @expedients.no_treated.order(sort_order)
    paginator = Paginator.new(@expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
  end

  def edit
    render layout: false
  end

  def update
    if @daily_agenda.update(update_params)
      redirect_to today_daily_agendas_path
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { redirect_to today_path }
      end
    end
  end

  def show
    render layout: false
  end

  def resolve
    @daily_agenda.solve
    flash[:notice] = 'La orden del día fue marcada como tratada correctamente'
    @daily_agenda = DailyAgenda.next_daily_agenda(@daily_agenda.destination)
    @daily_count = DailyAgenda.where(date: Date.today, destination: @daily_agenda.destination).count
    paginator = Paginator.new(@daily_agenda.expedients.ordered, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    @treated_count = 0
    @no_treated_count = 0
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to today_path }
    end
  end

  def add_expedients
    @daily_agenda = DailyAgenda.find(params[:id])
    @expedients = Expedient.for_destination(@daily_agenda.destination).by_subject_priority
    render layout: false
  end

  def attach_expedient
    @daily_agenda = DailyAgenda.find(params[:id])
    @daily_count = DailyAgenda.where(date: Date.today, destination: @daily_agenda.destination).count
    @expedients = Expedient.where(id: params[:expedient_ids])
    @daily_agenda.add_expedients!(@expedients)
    @expedients.update_all(daily_agenda_id: @daily_agenda.id)
    @treated_count = @daily_agenda.expedients.treated.count
    @no_treated_count = @daily_agenda.expedients.no_treated.count
    paginator = Paginator.new(@daily_agenda.expedients.ordered, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      flash[:notice] = "#{@expedients.count} expedientes agregado(s) correctamente"
      format.turbo_stream
      format.html { redirect_to today_daily_agendas_path }
    end
  end

  def download_pdf
    title = "Orden del día #{@daily_agenda.date}"
    respond_to do |format|
      format.pdf do
        render pdf: title, template: 'daily_agendas/daily_agenda_pdf'
      end
    end
  end

  def mark_as_treated_modal
    render layout: false
  end

  def mark_expedient_as_treated
    expedient = Expedient.find(params[:expedient_id])
    expedient.treated!
    expedient.update(treat_date: Date.today)

    flash[:notice] = "Expediente #{expedient.file_number} marcado como tratado"
    @expedients = @daily_agenda.expedients.ordered
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
      format.html { redirect_to today_daily_agendas_path }
    end
  end

  def modal_list
    @daily_agendas = DailyAgenda.where(date: params[:date])
    render layout: false
  end

  def edit_expedients
    @expedients = @daily_agenda.expedients.no_treated
  end

  def update_expedients_order
    ids = params[:order].to_s.split(',').map(&:to_i)

    valid_ids = ids.select do |id|
      @daily_agenda.expedients.exists?(id)
    end

    valid_ids.each_with_index do |id, index|
      @daily_agenda.expedients.find(id).update(position: index + 1)
    end

    flash[:notice] = 'Se actualizó la orden de los expedientes'
    if @daily_agenda.hcd?
      redirect_to today_daily_agendas_path
    else
      redirect_to destination_daily_agenda_path(destination_id: @daily_agenda.destination_id)
    end
  end

  private

  def update_params
    params.require(:daily_agenda).permit(:date)
  end

  def set_daily_agenda
    @daily_agenda = DailyAgenda.find(params[:id])
  end

  def build_calendar(date)
    start_date = date.beginning_of_month.beginning_of_week(:monday)
    end_date = date.end_of_month.end_of_week(:monday)

    (start_date..end_date).to_a
  end

  def filter_params
    params.permit(:file_number, :subject_id, :destination_id, :from_date, :to_date, :treated, :sort, :direction, :page)
  end

  def sort_order
    column = params[:sort].presence || 'file_number'
    direction = params[:direction].presence || 'asc'
    "#{column} #{direction}"
  end

  def set_destination
    @destination =
      if params[:destination_id].present?
        Destination.find(params[:destination_id])
      else
        Destination.find_by(name: 'Honorable Consejo Directivo')
      end
  end
end
