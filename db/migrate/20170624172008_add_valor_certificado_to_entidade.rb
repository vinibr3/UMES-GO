class AddValorCertificadoToEntidade < ActiveRecord::Migration
  def change
    add_column :entidades, :valor_certificado, :integer
  end
end
