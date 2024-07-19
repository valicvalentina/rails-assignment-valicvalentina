class Company < ApplicationRecord
  has_many :flights, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
