class Destination < ApplicationRecord
  validates :name, uniqueness: { message: 'El nombre ya existe' }
  validates :name, presence: { message: 'El nombre no puede estar vacío' }

  scope :active_first, -> { order(active: :desc) }
  scope :actives, -> { where(active: true) }
end
