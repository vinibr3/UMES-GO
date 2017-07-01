class AddSaldoToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :saldo, :float
  end
end
