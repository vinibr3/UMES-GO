class AddValorCertificadoToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :valor_certificado, :integer
  end
end
