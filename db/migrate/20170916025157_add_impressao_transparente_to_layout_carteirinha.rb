class AddImpressaoTransparenteToLayoutCarteirinha < ActiveRecord::Migration
  def change
    add_column :layout_carteirinhas, :impressao_transparente, :string, default: "0"
  end
end
