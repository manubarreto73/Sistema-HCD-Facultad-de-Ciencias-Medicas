class AddDailyAgendaDestinationReference < ActiveRecord::Migration[8.0]
  def change
    add_reference :daily_agendas, :destination, foreign_key: true, null: true
  end
end
