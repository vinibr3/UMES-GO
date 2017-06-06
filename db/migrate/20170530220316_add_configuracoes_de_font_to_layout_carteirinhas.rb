class AddConfiguracoesDeFontToLayoutCarteirinhas < ActiveRecord::Migration
  def change
    add_column :layout_carteirinhas, :font_color, :string
    add_column :layout_carteirinhas, :font_weight, :string
    add_column :layout_carteirinhas, :font_style, :string
    add_column :layout_carteirinhas, :font_name, :string
    add_column :layout_carteirinhas, :font_family, :string
    add_column :layout_carteirinhas, :font_box, :integer
  end
end
