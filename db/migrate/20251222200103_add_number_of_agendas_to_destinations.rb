class AddNumberOfAgendasToDestinations < ActiveRecord::Migration[8.0]
  def change
    add_column :destinations, :number_of_agendas, :integer, default: 1, null: false
    add_column :daily_agendas, :number, :integer, default: 0, null: false
  end
end
