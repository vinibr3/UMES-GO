class CreateExtensoes < ActiveRecord::Migration
  def change
    create_table :extensoes do |t|
      t.references :entidade, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
