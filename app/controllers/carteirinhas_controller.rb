class CarteirinhasController < ApplicationController

	before_action :authenticate_estudante!, 
								except: [:consulta, :show, :carteirinha_image, :status_versao_impressas]

	def show
		
	end

	def carteirinha_image
		@carteirinha = Carteirinha.find(params[:id])
		send_data @carteirinha.to_blob, :type=>"image/jpg", :disposition=>"inline"
	end

	def new
		
	end

	def create 
		atributos = current_estudante.atributos_nao_preenchidos
		if atributos.count > 0
			campos = ""
			atributos.collect{|f| campos.concat(f.to_s.humanize.concat(", "))}
			flash[:alert] = "Campo(s) #{campos} não preenchido(s)."
			redirect_to estudante_path(current_estudante)
		else
			@entidade = current_estudante.entidade
 			if @entidade && @entidade.layout_atual && @entidade.layout_atual.layout_alternativo 
 				current_estudante.verso_alternativo! if carteirinha_params[:verso_alternativo] == "1"
 			else
 				current_estudante.verso_normal!
 			end
 			current_estudante.save
			if carteirinha_params[:termos] == "0"
				flash[:alert] = "Os Termos de Serviço devem ser aceitos."
				redirect_to estudante_path(current_estudante)
			else
				redirect_to checkout_path(valor_carteirinha: carteirinha_params[:valor_carteirinha], frete_carteirinha: carteirinha_params[:frete_carteirinha])
			end	
		end
	end

	def consulta		
		@carteirinha = Carteirinha.find_by_codigo_uso(params[:carteirinha][:codigo_uso])
		if verify_recaptcha(model: @carteirinha)
			respond_to do |format|
				format.html{redirect_to consulta_url}
				format.js
			end
		else
		  redirect_to consulta_url
		end			
	end

	def status_versao_impressas
		@statuses = 
		Carteirinha.show_status_carteirinha_apartir_do_status_pagamento params[:status_pagamento]
		respond_to do |format|
			format.js
		end
	end

	private
		def carteirinha_params
			params.require(:carteirinha).permit(:valor_carteirinha, :termos, :frete_carteirinha, :status_pagamento, :verso_alternativo)
		end
end