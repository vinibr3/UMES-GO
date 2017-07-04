class AddLayoutToEstudantes < ActiveRecord::Migration
  def change
    add_column :estudantes, :layout, :integer, default: 0
  end
end
