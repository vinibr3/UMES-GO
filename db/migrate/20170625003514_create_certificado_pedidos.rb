class CreateCertificadoPedidos < ActiveRecord::Migration
  def change
    create_table :certificado_pedidos do |t|
      t.float :valor_unitario
      t.integer :quantidade
      t.float :valor_total
      t.references :admin_user, index: true, foreign_key: true
      t.string :status
      t.string :transacao
      t.string :forma_pagamento

      t.timestamps null: false
    end
  end
end
