class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks, dependent: :destroy
  has_many :schedules, dependent: :destroy
  belongs_to :location, optional: true

  validates :name, presence: true, length: { maximum: 20 }
  validates :location_id, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 1, 
    less_than_or_equal_to: 63,
    message: "を選択してください" 
  }
end
