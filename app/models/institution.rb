class Institution < ActiveRecord::Base
  has_many :repositories, dependent: :destroy
  validates :name, uniqueness: true, presence: true

end