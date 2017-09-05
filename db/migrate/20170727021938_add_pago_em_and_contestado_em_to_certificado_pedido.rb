class AddPagoEmAndContestadoEmToCertificadoPedido < ActiveRecord::Migration
  def change
    add_column :certificado_pedidos, :pago_em, :datetime
    add_column :certificado_pedidos, :contestado_em, :datetime
  end
end
