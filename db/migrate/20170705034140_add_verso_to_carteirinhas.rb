class AddVersoToCarteirinhas < ActiveRecord::Migration
  def change
    add_column :carteirinhas, :verso, :string, default: "0"
  end
end