ActiveAdmin.register CertificadoPedido do 
	menu priority: 7, if: proc{current_admin_user.show_no_menu?}
	actions :all, except: [:destroy, :edit]

	scope_to :current_admin_user, if: proc{current_admin_user.entidade}

	config.sort_order = 'created_at_desc'

	permit_params :quantidade

	filter :status, as: :select, collection: proc{CertificadoPedido.class_variable_get(:@@status_pagamentos)}
	filter :forma_pagamento, as: :select, collection: proc{CertificadoPedido.class_variable_get(:@@forma_pagamentos)}

	index do
		column :id
		column "Valor unitário (R$)" do |certificado_pedido|
			certificado_pedido.valor_unitario
		end
		column :quantidade
		column "Valor total (R$)" do |certificado_pedido|
			certificado_pedido.valor_total
		end
		column "Pagamento" do |certificado_pedido|
			status_tag(certificado_pedido.status, certificado_pedido.pago? ? :ok : :warning)
		end
		column "Transação" do |certificado_pedido|
			certificado_pedido.transacao
		end
		column "Forma pagamento" do |certificado_pedido|
			certificado_pedido.forma_pagamento
		end
		actions defaults: true do |certificado_pedido|
			link_to "Pagar", pagamento_admin_certificado_pedido_path(certificado_pedido) if certificado_pedido.status.blank?
		end
	end

	show do
		panel "Pedido" do
			attributes_table_for certificado_pedido do
				row "Valor unitário (R$)" do |certificado_pedido|
					certificado_pedido.valor_unitario
				end
				row :quantidade
				row "Valor total (R$)" do |certificado_pedido|
					certificado_pedido.valor_total
				end
				row "Usuário" do |certificado_pedido|
					certificado_pedido.admin_user_nome
				end if !current_admin_user.entidade || current_admin_user.sim?
				row "Pagamento" do |certificado_pedido|
					certificado_pedido.status
				end
				row "Transação" do |certificado_pedido|
					certificado_pedido.transacao
				end
				row "Forma pagamento" do |certificado_pedido|
					certificado_pedido.forma_pagamento
				end
			end
		end
	end

	form do |f|
		f.semantic_errors *f.object.errors.keys
		f.inputs "Pedido" do
			f.input :valor_unitario, label:"Valor unitário (R$)",:input_html => { :value => current_admin_user.valor_certificado }
			f.input :quantidade
			f.input :valor_total, label: "Valor Total (R$)" ,:input_html => { :value => f.object.calcula_valor_total}
		end
		f.actions
		# Script que altera valor total a partir do valor_unitario e quantidade
		render inline: "<script type='text/javascript'> 
							$('#certificado_pedido_valor_unitario').prop('disabled', true);
							$('#certificado_pedido_valor_total').prop('disabled', true);
							$('#certificado_pedido_quantidade').on('change', function(){
								var valor_unitario = parseInt($('#certificado_pedido_valor_unitario').val());
								var quantidade = parseInt($('#certificado_pedido_quantidade').val());
								console.log(valor_unitario);
								console.log(quantidade);
								$('#certificado_pedido_valor_total').val(valor_unitario*quantidade);
							});
						</script>"
	end

	before_update do |certificado_pedido|
		certificado_pedido.valor_total = certificado_pedido.valor_unitario*certificado_pedido.quantidade
	end

	before_create do |certificado_pedido|
		certificado_pedido.valor_unitario = current_admin_user.valor_certificado
		certificado_pedido.valor_total = certificado_pedido.valor_unitario*certificado_pedido.quantidade
		certificado_pedido.admin_user = current_admin_user
	end

	member_action :pagamento, method: :get do
		#email = "vinicius.deoliveira@outlook.com"
		#token = "92097C02DABA4056ACC98DDA16C118F3"
		description = "#{resource.quantidade} Certificados"
		redirect_url = "http://162.243.72.115/admin"
		notification_url = "http://162.243.72.115/admin/pagamento/notificacoes"
		usuario = resource.admin_user 
		
		payment = PagSeguro::PaymentRequest.new
		payment.reference = resource.id
		payment.notification_url = notification_url
		payment.redirect_url = redirect_url

		payment.items << {
			    id: resource.id,
			    quantity: resource.quantidade,
			    description: description,
			    amount: resource.valor_unitario
		}

		# Informações do comprador
		payment.sender = {
			name: usuario.nome_pagamento,
			email: usuario.email,
			phone: {
			    area_code: usuario.celular.first(2),
			    number: usuario.celular.from(2)
			}
		}

		payment.max_uses = 100
		payment.max_age = 3600  # em segundos

		response = payment.register

		# Se estiver tudo certo, redireciona o comprador para o PagSeguro.
		if response.errors.any?
			flash[:alert] = response.errors
			redirect_to :back
			#raise response.errors.join("\n")
		else
			redirect_to response.url
		end
	end

	action_item :pagar, only: :show, if: proc{current_admin_user.entidade} do
		link_to "Pagar", pagamento_admin_certificado_pedido_path(certificado_pedido) if certificado_pedido.status.blank?
	end

end