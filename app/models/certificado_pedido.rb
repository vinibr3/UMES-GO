class CertificadoPedido < ActiveRecord::Base
	belongs_to :admin_user

	validates_presence_of :valor_unitario, :quantidade, :valor_total, :admin_user
  
	@@forma_pagamentos = {cartao_de_credito: "Cartão de crédito", boleto: "Boleto", a_definir: "A definir",
										    debito_online: "Débito online", saldo_pagseguro: "Saldo PagSeguro", 
										    oi_pago: "Oi Paggo", deposito_em_conta: "Depósito em conta", dinheiro: "Dinheiro"}		   				

	@@status_pagamentos = {iniciado: "Iniciado", aguardando_pagamento: "Aguardando pagamento", em_analise: "Em análise",
							 				   pago: "Pago", disponivel: "Disponível", em_disputa: "Em disputa", devolvido: "Devolvido",
							 				   cancelado: "Cancelado", contestado: "Contestado"}

  	enum forma_pagamento: @@forma_pagamentos
  	enum status: @@status_pagamentos

  	def admin_user_nome
  		self.admin_user.nome if self.admin_user
  	end	

  	def calcula_valor_total
  		self.valor_unitario*self.quantidade if self.valor_unitario && self.quantidade
  	end

  	def self.forma_pagamento_by_type type
		formas = CertificadoPedido.forma_pagamentos.map{|k,v| k}
		forma = ''
		case type
		when "1" then forma = formas[0] # Cartão de Crédito
		when "2" then forma = formas[1] # Boleto
		when "3" then forma = formas[3] # Débito on-line
		when "4" then forma = formas[4] # Saldo Pag-seguro
		when "5" then forma = formas[5] # Oi pago
		when "7" then forma = formas[6] # Depósito em conta
		else forma = formas[2] # a definir
		end
		forma 
	end

	def self.status_pagamento_by_code code
 		statuses = CertificadoPedido.statuses.map{|k,v| k}
 		if 1 < code.to_i && code.to_i < 7
 			return statuses[code.to_i]
 		else
 			return statuses[0] # Iniciado
 		end
 	end

end
