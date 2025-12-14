class CreateDailyAgendaExpedientHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_agenda_expedient_histories do |t|
      t.references :daily_agenda, null: false, foreign_key: true
      t.references :expedient, null: false, foreign_key: true
      t.references :previous_destination, null: false, foreign_key: { to_table: :destinations }
      t.references :new_destination, null: false, foreign_key: { to_table: :destinations }

      t.timestamps
    end
  end
end
