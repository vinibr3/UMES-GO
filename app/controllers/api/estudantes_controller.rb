class Api::EstudantesController < Api::AuthenticateBase
	before_action :http_token_authentication

	def show
		@estudante = Estudante.find_by_oauth_token params[:oauth_token]
		if @estudante
			respond_with @estudante
		else
			render_erro "Estudante não encontrado", 404
		end
	end

	def update
		# begin 
			@estudante = Estudante.find(estudante_params[:id])
			if @estudante
				parametros = serialize_estudante(estudante_params)
				if @estudante.update_attributes(parametros)
					respond_with @estudante
				else
					render_erro @estudante.errors, 422
				end
			else
				render_erro "Estudante não encontrado. Email: #{params[:estudante][:email]}", 404
			end
		# rescue Exception => ex
		# 	render json: {errors: ex.message}, :status => 500
		# end
	end

	private
		def estudante_params
			params.require(:estudante).permit(:nome, :cpf, :rg, :data_nascimento, :sexo, :telefone,
											  :matricula, :foto, :comprovante_matricula, :xerox_rg, :email, :password, 
											  :celular, :id, :provider, :oauth_token,:expedidor_rg, :uf_expedidor_rg, 
											  :xerox_cpf, :foto_file_name, :comprovante_matricula_file_name, :xerox_rg_file_name, 
											  :xerox_cpf_file_name, :foto_content, :xerox_rg_content, 
											  :xerox_cpf_content, :comprovante_matricula_content,
											  :endereco => [:logradouro, :complemento, :setor, :cep, :cidade_id, :numero, :setor],
											  :instituicao_ensino => [:id, :nome, :sigla, :cidade, :estado, :cidade_id],
											  :curso => [:id, :nome, :escolaridade])
		end

		def parse_image file_name, file_content, parametros
			image = Paperclip.io_adapters.for(parametros[file_content]) 
			image.original_filename = parametros[file_name]
			image
		end

		def serialize_estudante parametros
			parametros = serialize_anexos(parametros)
			parametros[:instituicao_ensino] = serialize_instituicao_ensino estudante_params[:instituicao_ensino]
			parametros[:curso] = serialize_curso estudante_params[:curso]
			parametros = serialize_endereco estudante_params[:endereco], parametros
			parametros
		end

		def serialize_anexos parametros
			['foto', 'xerox_rg', 'xerox_cpf', 'comprovante_matricula'].each do |v|
				file_name = "#{v}_file_name".to_sym
				file_content = "#{v}_content".to_sym
				if parametros[file_content].nil?
					parametros.delete(file_name)
					parametros.delete(file_content)
				else
					parametros[v.to_sym] = parse_image(file_name, file_content, parametros)
				end 
			end
			parametros
		end

		def serialize_instituicao_ensino instituicao_ensino
			instituicao = nil
			atributes = instituicao_ensino.slice(:nome, :cidade_id).delete_if{|k,v| v == nil || v == ""}
			if !atributes.empty?
				instituicao = InstituicaoEnsino.where(atributes).first_or_create do |c|
					c.nome = atributes[:nome]
					c.cidade_id = atributes[:cidade_id]
				end
			end
			instituicao
			

			# if instituicao_ensino[:id].nil?
			# 	estado = Estado.find_by_sigla(instituicao_ensino[:estado])
			# 	cidade = nil;
			# 	cidade = Cidade.where(estado_id: estado.id, nome: instituicao_ensino[:nome]) if estado
				
			# 	nova_instituicao = InstituicaoEnsino.where(nome: instituicao_ensino[:nome]).first_or_create do |instituicao_ensino|
			# 						instituicao_ensino.nome = instituicao_ensino[:nome]
			# 						instituicao_ensino.cidade = cidade if cidade
			# 	end
			# 	return nova_instituicao
			# else
			# 	return InstituicaoEnsino.find(instituicao_ensino[:id])
			# end
			
		end

		def serialize_curso curso
			logger.debug "Curso #{curso.inspect}"
			if curso[:id].nil?
				escolaridade = Escolaridade.find_by_nome(curso[:escolaridade]) 
				novo_curso = Curso.where(nome: curso[:nome], escolaridade: escolariade).first_or_create do |c|
								c.nome = curso[:nome]
								c.escolariade = escolariade if escolaridade
							 end
				return novo_curso
			else
				return Curso.find(curso[:id])
			end
		end

		def serialize_endereco endereco, parametros
			parametros[:logradouro] = endereco[:logradouro]
			parametros[:numero] = endereco[:numero] 
			parametros[:setor] = endereco[:setor] 
			parametros[:complemento] = endereco[:comprovante_matricula]
			parametros[:cep] = endereco[:cep]
			parametros[:cidade] = Cidade.find(endereco[:cidade_id])
			parametros.delete(:endereco)
			parametros
		end
end