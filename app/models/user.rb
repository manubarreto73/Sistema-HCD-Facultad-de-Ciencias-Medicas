class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validate :password_complexity

  validates :name, presence: true

  private

  def password_complexity
    return if password.blank?

    errors.add(:password, :weak_password) unless password =~ /^(?=.*[A-Z])(?=.*\d).{8,16}$/
  end
end
