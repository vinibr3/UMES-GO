class CheckoutController < ApplicationController
  
  before_filter :authenticate_estudante!

  def create
    # O modo como você irá armazenar os produtos que estão sendo comprados
    # depende de você. Neste caso, temos um modelo Order que referência os
    # produtos que estão sendo comprados.

    payment = PagSeguro::PaymentRequest.new
    payment.reference = current_estudante.id
    payment.notification_url = ENV['PAGSEGURO_URL_NOTIFICATION']
    payment.redirect_url = ENV['PAGSEGURO_URL_CALLBACK']

    # Informações de pagamento da carteirinha
    payment.items << {
      id: current_estudante.id,
      quantity: 1,
      description: "Carteira de Identificação Estudantil",
      amount: params[:valor_carteirinha]
    }

    # Taxa de serviço do pagseguro
    # valor_total = entidade.valor_carteirinha.to_f unless entidade.valor_carteirinha.blank?
    # valor_total += entidade.frete_carteirinha.to_f unless entidade.frete_carteirinha.blank?
    # amount = (valor_total+0.4)/0.95
    # amount = amount-valor_total
    payment.items << {
      id: current_estudante.id,
      quantity: 1,
      description: "Frete",
      amount: params[:frete_carteirinha],
      shipping_cost: params[:frete_carteirinha],
    } if params[:frete_carteirinha]
    
    # Informações do comprador
    payment.sender = {
      name: current_estudante.nome,
      email: current_estudante.email,
      phone: {
        area_code: current_estudante.celular.first(2),
        number: current_estudante.celular.from(2)
      }
    }

    # Configurações de envio
    payment.shipping = {
      type_name: 'not_specified',
      cost: params[:frete_carteirinha],
      address: {
        street: current_estudante.logradouro,
        number: current_estudante.numero,
        complement: current_estudante.complemento,
        district: current_estudante.setor,
        city: current_estudante.cidade,
        state: current_estudante.uf,
        postal_code: current_estudante.cep
      }
    } if params[:frete_carteirinha]

    payment.max_uses = 100
    payment.max_age = 3600  # em segundos

    # Caso você precise passar parâmetros para a api que ainda não foram mapeados na gem,
    # você pode fazer de maneira dinâmica utilizando um simples hash.
    # payment.extra_params << { paramName: 'paramValue' }
    # payment.extra_params << { senderBirthDate: '07/05/1981' }
    # payment.extra_params << { extraAmount: '-15.00' }

    response = payment.register

    # Caso o processo de checkout tenha dado errado, lança uma exceção.
    # Assim, um serviço de rastreamento de exceções ou até mesmo a gem
    # exception_notification poderá notificar sobre o ocorrido.
    #
    # Se estiver tudo certo, redireciona o comprador para o PagSeguro.
    if response.errors.any?
      flash[:alert] = response.errors
      redirect_to :back
      #raise response.errors.join("\n")
    else
      redirect_to response.url
    end
  end

  def confirmacao
    @transaction_id = params[:transaction_id]
  end

  def checkout_params
  	params.require(:checkout).permit(:estudante_id, :oauth_token)
  end

end