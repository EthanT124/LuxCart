class CreateActivties < ActiveRecord::Migration[7.1]
  def change
    create_table :activties do |t|
      t.string :title
      t.date :date
      t.time :time
      t.string :description
      t.integer :admin_id
      t.string :admin_username

      t.timestamps
    end
  end
end
