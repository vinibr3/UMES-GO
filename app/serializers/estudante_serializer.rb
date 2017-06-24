class EstudanteSerializer < ActiveModel::Serializer
  ActiveModel::Serializer.root = false
  attributes :type, :id, :nome, :email,:encrypted_password, :data_nascimento,
  			 :cpf, :rg, :expedidor_rg, :uf_expedidor_rg, :sexo, :telefone, :celular, :foto_file_name, 
  			 :foto_content, :foto_url, :foto_file_size, :foto_content_type, :xerox_rg_file_name, :xerox_rg_content, :xerox_rg_url, 
  			 :xerox_rg_file_size, :xerox_rg_content_type, :xerox_cpf_file_name, :xerox_cpf_content, :xerox_cpf_url, :xerox_cpf_file_size,
  			 :xerox_cpf_content_type, :comprovante_matricula_file_name, :comprovante_matricula_content, :comprovante_matricula_url, 
  			 :comprovante_matricula_file_size, :comprovante_matricula_content_type,:instituicao_ensino, :curso, :matricula, :oauth_token, 
  			 :oauth_expires_at, :provider, :endereco, :carteirinha_valida

 	def id
 		object.id.to_s if object.id
 	end

 	def carteirinha_valida
 		carteirinha = object.last_valid_carteirinha
 		carteirinha.nil? ? nil : CarteirinhaSerializer.new(carteirinha) 
 	end

 	def type
 		'estudante'
 	end

 	def instituicao_ensino
 		InstituicaoEnsinoSerializer.new(object.instituicao_ensino)
 	end

 	def curso
 		CursoSerializer.new(object.curso)
 	end

 	def foto_url
 		object.foto.url
 	end

 	def xerox_rg_url
 		object.xerox_rg.url
 	end

 	def xerox_cpf_url
 		object.xerox_cpf.url
 	end

 	def comprovante_matricula_url
 		object.comprovante_matricula.url	
 	end

 	def foto_content
 	end

 	def xerox_rg_content
 	end

 	def xerox_cpf_content
 	end

 	def comprovante_matricula_content
 	end

end