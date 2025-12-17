class DailyAgendaExpedientHistory < ApplicationRecord
  belongs_to :daily_agenda
  belongs_to :expedient

  belongs_to :previous_destination,
             class_name: 'Destination'

  belongs_to :new_destination,
             class_name: 'Destination'
end
