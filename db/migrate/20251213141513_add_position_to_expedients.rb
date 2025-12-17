class AddPositionToExpedients < ActiveRecord::Migration[8.0]
  def change
    add_column :expedients, :position, :integer, null: true
  end
end
