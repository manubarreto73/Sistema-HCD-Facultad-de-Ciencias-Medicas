class ExpedientHistory < ApplicationRecord
  belongs_to :user
  belongs_to :expedient

  enum :action, {
    creation: 0,
    modify: 1,
    deletion: 2
  }

  def action_name
    case action
    when 'creation'
      'Creación'
    when 'modify'
      'Actualización'
    when 'deletion'
      'Borrado'
    end
  end

  def title
    description.split(': ').first.concat(':')
  end

  def rows
    description.split(': ').last.split("\n ")
  end
end