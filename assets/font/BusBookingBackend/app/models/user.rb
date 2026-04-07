class User < ApplicationRecord
  devise :database_authenticatable, :validatable

  ROLES = %w[passenger operator admin].freeze
  enum :role, { passenger: 'passenger', operator: 'operator', admin: 'admin' }
  has_many :bus_operators, dependent: :destroy
  has_many :bookings,     dependent: :destroy
  has_many :reviews,      dependent: :destroy
  has_many :locked_seats, class_name: 'TripSeat',
                          foreign_key: :locked_by_user,
                          dependent: :nullify
  validates :name,  presence: true
  validates :phone, presence: true, uniqueness: true
  validates :role,  presence: true

  def admin?     = role == 'admin'
  def operator?  = role == 'operator'
  def passenger? = role == 'passenger'

  def generate_jwt
    JWT.encode(
      { sub: id, 
        exp: 24.hours.from_now.to_i 
      },
      ENV['DEVISE_JWT_SECRET_KEY'],
      'HS256'
    )  
  end
end