class CreateExpedients < ActiveRecord::Migration[8.0]
  def change
    create_table :expedients do |t|
      t.string :file_number, null: false
      t.string :responsible, null: false
      t.string :detail, null: false
      t.string :opinion
      t.datetime :creation_date
      t.integer :file_status, default: 0
      t.references :destination, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.timestamps
    end
  end
end
