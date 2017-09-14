class Api::CarteirinhasController < Api::AuthenticateBase

	before_action :http_base_authentication_with_entidade_data, only: [:index]
	before_action :http_token_authentication, only: [:show, :create]

	def index
		status = Carteirinha.class_variable_get(:@@status_versao_impressas)[:aprovada]
		@carteirinhas = Carteirinha.where("status_versao_impressa = ? AND certificado IS NULL", status)
		if @carteirinhas.empty?
			render_erro "Nenhuma Carteira de Identificação Estudantil com status #{status} encontrada.", 404
		else
			entidade = Entidade.entidade_padrao
			if entidade
				extensao = entidade.extensoes.first
				if extensao
					auth_info_url = Entidade.cadeia_certificados_raiz_url(entidade.id)
					crl_url = Entidade.lista_certificados_revogados_url(entidade.id)
					if auth_info_url && crl_url
						json = {:entidade => {:auth_info_access => auth_info_url, 
										  :crl_dist_points => crl_url, 
					        			  :carteirinhas => @carteirinhas.map{|c| CarteirinhaSerializer.new(c)}}}
						respond_with json
					else
						render_erro "'Autoridade de Acesso à Informação' e/ou 'CRL Ponto de Distribuição' não estão preenchidos.", 500 
					end
				else
					render_erro "Entidade não possui nenhuma Extensão cadastrada.", 500
				end
			else
				render_erro "Nenhuma entidade encontrada.", 404
			end
		end
	end

	def show
		begin
			@estudante = Estudante.find_by_oauth_token(params[:estudante_oauth_token])
			if @estudante
				if @estudante.carteirinha.empty?
		    	render_erro "Nenhuma Carteira de Identificação Estudantil encontrada.", 404
		    else
		    	respond_with @estudante.carteirinha.last, :status => 200
		    end
		  else
		  	render_erro "Estudante não encontrado, oauth_token: #{params[:estudante_oauth_token]}", 404
		  end
		rescue Exception => ex
			render_erro ex.message, 500
		end
	end

	def create
		begin 
			@estudante = Estudante.find_by_oauth_token(params[:estudante_oauth_token])
			if @estudante
				if @estudante.atributos_em_branco.empty?
					@carteirinhas = @estudante.carteirinha
					if @carteirinhas && @carteirinhas.last && @carteirinhas.last.em_solicitacao?
						@last_carteirinha = @carteirinhas.last
						message = "Carteira de Identificação Estudantil já solicitada"
						render json: {erros: message, status_versao_impressa: @last_carteirinha.status_versao_impressa,
							            type: 'erro'}, :status => 422
					else
						nova_carteirinha = @estudante.carteirinha.new(carteirinha_params) do |c|
							c.nome = @estudante.nome
							c.instituicao_ensino = @estudante.instituicao_ensino
							c.curso_serie = @estudante.curso_serie
							c.matricula = @estudante.matricula
							c.rg_certidao = @estudante.rg_certidao
							c.data_nascimento = @estudante.data_nascimento
							c.cpf = @estudante.cpf
							c.foto = @estudante.foto
						end	
						if nova_carteirinha.save
							# Metodo que envia boleto aqui
							respond_with nova_carteirinha, :status => 201
						else
							render json: {errors: nova_carteirinha.errors, type: 'erro'}, :status => 422
						end
					end
				else
					atributos_em_branco = @estudante.atributos_em_branco.to_s
					render_erro "Dados não preenchidos: #{atributos_em_branco}", 422
				end
			else
				render_erro "Estudante não encontrado, oauth_token: #{params[:estudante_oauth_token]}", 404
			end
		rescue => ex
			render_erro ex.message, 500
		end
	end

	private 
		def carteirinha_params
			params.require(:carteirinha).permit(:valor, :status_versao_impressa)
		end
end