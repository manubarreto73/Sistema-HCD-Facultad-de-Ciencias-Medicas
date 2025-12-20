module ApplicationHelper
  def error_class(resource, field)
    resource.errors[field].any? ? 'border-red-500 ring-red-200 focus:border-red-600' : ''
  end

  def pagination_params(overrides = {})
    allowed = %i[
      file_number
      subject_id
      destination_id
      from_date
      to_date
      treated
      page
      sort
      direction
    ]

    params.permit(allowed).to_h.merge(overrides).compact
  end

  def pagination_params_agenda(overrides = {})
    allowed = %i[
      treated
      page
      sort
      direction
    ]

    params.permit(allowed).to_h.merge(overrides).compact
  end

  def agenda_path(daily_agenda, options = {})
    return today_daily_agendas_path(params: options) if daily_agenda.hcd?

    return today_daily_agendas_path(params: options) unless daily_agenda.destination.present?

    destination_daily_agenda_path(
      destination_id: daily_agenda.destination.id,
      params: options
    )
  end

  def index_treated_title(destination)
    if destination.is_hcd
      'Ordenes del día tratadas'
    else
      "Ordenes del destino #{destination.name} tratadas"
    end
  end

  def treated_path(daily_agenda)
    classes = 'hover:bg-gray-100 p-1'
    if daily_agenda.hcd?
      link_to 'Marcar como tratada', mark_as_treated_modal_daily_agenda_path(@daily_agenda), data: { turbo_frame: 'modal' }, class: classes
    else
      link_to 'Marcar como tratada', destination_daily_agendas_treat_path(daily_agenda), class: classes
    end
  end
end
