class Expedient < ApplicationRecord
  belongs_to :subject, optional: true
  belongs_to :destination, optional: true
  belongs_to :daily_agenda, optional: true
  has_many :expedient_histories, dependent: :destroy

  has_many :daily_agenda_histories,
         class_name: "DailyAgendaExpedientHistory",
         dependent: :nullify

  validates :file_number, uniqueness: { message: 'El número de expediente ya existe' }
  validates :file_number, presence: { message: 'El número de expediente no puede estar vacío' }
  validates :file_number, length: { minimum: 22, message: 'El número de expediente es corto' }
  validates :responsible, length: { maximum: 50, message: 'El nombre del responsable es muy largo (máximo 30 carácteres)' }
  validates :responsible, presence: { message: 'El responsable no puede estar vacío' }
  validates :opinion, length: { maximum: 200, message: 'El dictámen es muy largo (máximo 200 caracteres)' }
  validates :opinion, presence: { message: 'El dictámen no puede estar vacío' }
  validates :detail, length: { maximum: 200, message: 'El detalle es muy largo (máximo 200 carácteres)' }
  validates :detail, presence: { message: 'El detalle no puede estar vacío' }
  validates :subject, presence: { message: 'Tenés que elegir un tema'}
  validates :destination, presence: { message: 'Tenés que elegir un destino'}

  enum :file_status, {
    no_treated: 0,
    treated: 1,
    deleted: 2
  }

  scope :treated, -> { where(file_status: 'treated') }
  scope :no_treated, -> { where(file_status: 'no_treated') }
  scope :for_destination, ->(destination) {
    where(
      file_status: 'no_treated',
      destination_id: destination&.id,
      daily_agenda_id: nil
    )
  }
  scope :ordered, -> { order(:position) }
  scope :by_subject_priority, -> {
    joins(:subject).order("subjects.priority ASC")
  }
  # Metodos para mejorar la info de las vistas

  FIELD_TRANSLATIONS = {
    'file_number' => 'Número de Expediente',
    'responsible' => 'Responsable',
    'subject_id' => 'Tema',
    'destination_id' => 'Destino',
    'priority' => 'Prioridad',
    'opinion' => 'Dictamen',
    'detail' => 'Detalle',
    'creation_date' => 'Fecha de creación',
    'treat_date' => 'Fecha de tratado'
  }.freeze

  def status
    case file_status
    when 'no_treated'
      'No tratado'
    when 'treated'
      'Tratado'
    else
      'Eliminado'
    end
  end

  def dependency
    return '' unless file_number

    file_number.split('-')[0]
  end

  def file_digits
    return '' unless file_number

    file_number.split('-')[1].split('/')[0]
  end

  def file_year
    return '' unless file_number

    file_number.split('-')[1].split('/')[1]
  end

  def correspondence
    return '' unless file_number

    file_number.split('-')[2]
  end

  def logic_delete(current_user)
    deleted!
    expedient_histories.create(action: 2, description: nil, user: current_user)
    update(subject: nil, destination: nil, daily_agenda: nil, file_number: "#{file_number}* [DELETED]")
  end

  def deleted_info
    info = expedient_histories.deletion.last
    {
      file_number: file_number.gsub('* [DELETED]', ''),
      user: info.user.name,
      date: info.created_at.strftime('%d/%m/%Y %H:%M')
    }
  end

  def priority
    subject&.priority || 0
  end

  def create_history(current_user)
    expedient_histories.create(action: 0, description: "Se creó el expediente #{file_number}", user: current_user)
  end

  def modify_history(current_user)
    description = 'Se actualizaron los campos (valor anterior, valor actual): '
    saved_changes.except('updated_at').each do |change|
      key = change[0]
      if key == 'subject_id'
        old_value = Subject.find(change[1][0]).name
        new_value = subject.name
      elsif key == 'destination_id'
        old_value = Destination.find(change[1][0]).name
        new_value = destination.name
      elsif key == 'creation_date'
        old_value = change[1][0].in_time_zone.strftime("%Y-%m-%d")
        new_value = change[1][1].in_time_zone.strftime("%d-%m-%Y")
      else 
        old_value = change[1][0]
        new_value = change[1][1]
      end
      description << " #{FIELD_TRANSLATIONS[key]} (#{old_value}, #{new_value}). "
    end

    expedient_histories.create(action: 1, description: description, user: current_user)
  end
end
