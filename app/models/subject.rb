class Subject < ApplicationRecord
  validates :name, uniqueness: { message: 'El nombre ya existe' }
  validates :name, presence: { message: 'El nombre no puede estar vacío' }
end
