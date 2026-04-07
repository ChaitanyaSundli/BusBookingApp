class Bus < ApplicationRecord
  belongs_to :bus_operator
  has_many :seats, dependent: :destroy
  has_many :trips, dependent: :destroy
  before_save :normalize_bus_type

  BUS_TYPES = %w[ac_seater non_ac_seater ac_sleeper non_ac_sleeper].freeze
  
  enum :bus_type, {
    ac_seater: 'ac_seater',
    non_ac_seater: 'non_ac_seater',
    ac_sleeper: 'ac_sleeper',
    non_ac_sleeper: 'non_ac_sleeper'
  }, prefix: false
  
  validates :bus_no, :bus_name, :bus_type, :deck, presence: true
  validates :bus_no, uniqueness: true
  scope :active, -> { where(is_active: true) }
  private
  def normalize_bus_type
  self.bus_type = bus_type.to_s.downcase.strip
  end
end
