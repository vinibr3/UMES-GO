class RemoveColumnNumeroSerieFromCarteirinhas < ActiveRecord::Migration
  def change
    remove_column :carteirinhas, :numero_serie, :string
  end
end
