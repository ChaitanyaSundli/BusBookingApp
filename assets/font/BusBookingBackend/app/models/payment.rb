class Payment < ApplicationRecord
  belongs_to :booking
  enum :status, {
    pending:  0,
    success:  1,
    failed:   2,
    refunded: 3
  }
  validates :amount, presence: true, numericality: { greater_than: 0 }
end