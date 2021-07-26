class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :url
      t.datetime :last_checked_at
      t.references :check_status

      t.timestamps
    end
  end
end
