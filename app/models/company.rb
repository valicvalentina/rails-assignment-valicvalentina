class Company < ApplicationRecord
  has_many :flights, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :with_active_flights, lambda {
    joins(:flights).where('flights.departs_at > ?', Time.current).distinct
  }
end
