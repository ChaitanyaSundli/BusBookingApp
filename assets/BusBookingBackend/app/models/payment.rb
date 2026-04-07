class Payment < ApplicationRecord
  belongs_to :booking
  enum :status, {
    pending:  'pending',
    success:  'success',
    failed:   'failed',
    refunded: 'refunded'
  }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end