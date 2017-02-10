class AddAprovadaEmToCarteirinhas < ActiveRecord::Migration
  def change
    add_column :carteirinhas, :aprovada_em, :datetime
  end
end
