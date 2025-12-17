class DailyAgenda < ApplicationRecord
  has_many :expedients, dependent: :nullify
  belongs_to :destination, optional: true

  has_many :expedient_histories,
         class_name: "DailyAgendaExpedientHistory",
         dependent: :destroy

  def solve
    expedients.update_all(file_status: 'treated', treat_date: Date.today)
  end

  def undo_solve
    expedients.update_all(file_status: 'no_treated')
  end

  def date_name
    "#{I18n.l(date, format: '%a')} #{date.day}"
  end

  def treated?
    return false unless expedients.any?

    expedients.all? { |exp| exp.file_status == 'treated' }
  end

  def hcd?
    destination.name == 'Honorable Consejo Directivo'
  end

  def self.next_daily_agenda(destination)
    today_agendas = where(date: Date.today, destination: destination)
    exists = today_agendas.any?
    return create(date: Date.today, destination: destination) unless exists

    not_treated = today_agendas.find { |d| !d.treated? }
    not_treated || create(date: Date.today, destination: destination)
  end

  def add_expedient!(expedient)
    transaction do
      insert_position = calculate_position_for(expedient)

      shift_positions_from(insert_position)

      expedient.update!(
        daily_agenda: self,
        position: insert_position
      )
    end
  end

  def add_expedients!(expedients)
    transaction do
      expedients
        .sort_by { |e| e.subject.priority }
        .each do |expedient|
          puts "#{expedient.file_number} - #{expedient.subject.priority}"
          add_single_expedient!(expedient)
        end
    end
  end

  def reorder_positions_from!(start_position)
    expedients
      .where("position > ?", start_position)
      .order(:position)
      .each_with_index do |expedient, index|
        expedient.update!(position: start_position + index)
      end
  end

  private

  def add_single_expedient!(expedient)
    insert_position = calculate_position_for(expedient)

    shift_positions_from(insert_position)

    expedient.update!(
      daily_agenda: self,
      position: insert_position
    )
  end

  def calculate_position_for(expedient)
    expedients
      .joins(:subject)
      .where("subjects.priority < ?", expedient.subject.priority)
      .count + 1
  end

  def shift_positions_from(position)
    expedients
      .where("position >= ?", position)
      .update_all("position = position + 1")
  end
end
