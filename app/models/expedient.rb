class Expedient < ApplicationRecord
  belongs_to :subject
  belongs_to :destination

  enum :file_status, {
    no_treated: 0,
    treated: 1,
    deleted: 2
  }

  scope :treated, -> { where(file_status: 'treated') }
  scope :no_treated, -> { where(file_status: 'no_treated') }
end
