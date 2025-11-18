class CreateDestinations < ActiveRecord::Migration[8.0]
  def change
    create_table :destinations do |t|
      t.string :name, null: false
      t.boolean :is_commission, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :destinations, :name, unique: true
  end
end
