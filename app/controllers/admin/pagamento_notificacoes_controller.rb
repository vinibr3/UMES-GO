class Admin::PagamentoNotificacoesController < ApplicationController
	def notificacoes
		email = ENV['DOTI_PAGSEGURO_EMAIL']
        token = ENV['DOTI_PAGSEGURO_TOKEN']
        transaction = PagSeguro::Transaction.find_by_notification_code(params[:notificationCode], {:email => email, :token => token })
    	if transaction.errors.empty?
    		@certificado_pedido = CertificadoPedido.find(transaction.reference)
    		@certificado_pedido.forma_pagamento = CertificadoPedido.forma_pagamento_by_type(transaction.payment_method.type_id)
    		@certificado_pedido.transacao = transaction.code
    		status = CertificadoPedido.status_pagamento_by_code(transaction.status.id).to_sym
    		status_pagamento_atual = @certificado_pedido.status
    		if ((status == :pago || status == :disponivel) && @certificado_pedido.pago_em.blank?) # add saldo
    			@admin_user = @certificado_pedido.admin_user
    			@admin_user.add_saldo @certificado_pedido.valor_total
    			@admin_user.save
                @certificado_pedido.pago_em = Time.new
    		elsif ((status == :contestado || status == :em_disputa || status == :devolvido) && @certificado_pedido.contestado_em.blank?) # remove saldo
    			@admin_user = @certificado_pedido.admin_user
    			@admin_user.remove_saldo @certificado_pedido.valor_total
    			@admin_user.save
                @certificado_pedido.contestado_em = Time.new
    		else
    		end
    		@certificado_pedido.status = status
    		@certificado_pedido.save
    	end
    	render nothing: true, status: 200 
	end
end