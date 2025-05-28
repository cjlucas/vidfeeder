class CreateYoutubePlaylists < ActiveRecord::Migration[8.0]
  def change
    create_table :youtube_playlists do |t|
      t.string :playlist_id

      t.timestamps
    end
  end
end
