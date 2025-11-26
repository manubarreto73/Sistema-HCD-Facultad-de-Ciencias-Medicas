class Subject < ApplicationRecord
  validates :name, uniqueness: { message: 'El nombre ya existe' }
  validates :name, presence: { message: 'El nombre no puede estar vacío' }
  validates :name, length: { maximum: 30, message: 'El nombre del tema muy largo (máximo 30 carácteres)' }

end
