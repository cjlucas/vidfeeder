class YoutubePlaylist < ApplicationRecord
  has_many :subscriptions, as: :source

  validates :playlist_id, presence: true
end
