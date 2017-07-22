class Api::CheckoutController < Api::AuthenticateBase
	before_action :http_token_authentication
	def create

		@estudante = Estudante.find(checkout_params[:estudante_id])
		@entidade = @estudante.entidade

	    payment = PagSeguro::PaymentRequest.new
	    payment.reference = @estudante.id
	    payment.notification_url = ENV['PAGSEGURO_URL_NOTIFICATION']
	    payment.redirect_url = ENV['PAGSEGURO_URL_CALLBACK']

	    # Informações de pagamento da carteirinha
	    payment.items << {
	      id: @estudante.id,
	      quantity: 1,
	      description: "Carteira de Identificação Estudantil",
	      amount: @entidade.valor_carteirinha
	    }

	    payment.items << {
	      id: @estudante.id,
	      quantity: 1,
	      description: "Frete",
	      amount: @entidade.frete_carteirinha,
	      shipping_cost: @entidade.frete_carteirinha,
	    } unless @entidade.frete_carteirinha.blank?
	    
	    # Informações do comprador
	    payment.sender = {
	      name: @estudante.nome,
	      email: @estudante.email,
	      phone: {
	        area_code: @estudante.celular.first(2),
	        number: @estudante.celular.from(2)
	      }
	    }

	    # Configurações de envio
	    payment.shipping = {
	      type_name: 'not_specified',
	      cost: @entidade.valor_carteirinha,
	      address: {
	        street: @estudante.logradouro,
	        number: @estudante.numero,
	        complement: @estudante.complemento,
	        district: @estudante.setor,
	        city: @estudante.cidade,
	        state: @estudante.uf,
	        postal_code: @estudante.cep
	      }
	    } unless @entidade.frete_carteirinha.blank?

	    payment.max_uses = 100
	    payment.max_age = 3600  # em segundos

	    response = payment.register

	    if response.errors.any?
	      render_erro response.errors, 200
	    else
	     	render json: {url: response.url, type: "url"}
	    end
	end

	def checkout_params
  		params.permit(:estudante_id)
  	end
end