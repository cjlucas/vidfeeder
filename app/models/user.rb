class User < ApplicationRecord
  has_many :subscriptions
  
  validates :email, presence: true
end
