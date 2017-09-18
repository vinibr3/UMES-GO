class AddAnversoConfigurationsToLayoutCarteirinhas < ActiveRecord::Migration
  def change
    add_column :layout_carteirinhas, :anverso_resolution_x, :float
    add_column :layout_carteirinhas, :anverso_resolution_y, :float
    add_column :layout_carteirinhas, :anverso_width, :integer
    add_column :layout_carteirinhas, :anverso_height, :integer
  end
end
