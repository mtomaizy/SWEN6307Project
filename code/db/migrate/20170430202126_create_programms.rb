class CreateProgramms < ActiveRecord::Migration[5.0]
  def change
    create_table :programms do |t|
      t.string :name
      t.string :university
      t.integer :mingrade
      t.string :description

      t.timestamps
    end
  end
end
