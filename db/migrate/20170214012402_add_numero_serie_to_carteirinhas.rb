class AddNumeroSerieToCarteirinhas < ActiveRecord::Migration
  def change
    add_column :carteirinhas, :numero_serie, :bigint
  end
end
