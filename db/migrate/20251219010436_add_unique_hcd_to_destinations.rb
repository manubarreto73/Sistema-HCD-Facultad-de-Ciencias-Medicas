class AddUniqueHcdToDestinations < ActiveRecord::Migration[7.0]
  def change
    add_index :destinations,
              :is_hcd,
              unique: true,
              where: "is_hcd = true",
              name: "unique_hcd_destination"
  end
end