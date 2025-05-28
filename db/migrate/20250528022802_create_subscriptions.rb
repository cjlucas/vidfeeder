class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.bigint :user_id
      t.bigint :source_id
      t.string :source_type
      t.timestamps
    end
  end
end
