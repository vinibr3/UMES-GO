class EstudantesController < ApplicationController

	before_action :authenticate_estudante!

	def show
		@estudante = current_estudante
		@carteirinhas = current_estudante.carteirinhas.each{|carteirinha| carteirinha if carteirinha}
		@entidade = Entidade.entidade_padrao
	end	

	def update
		@atribute_updated = estudante_params.map{|k,v| k}.first if request.format.js?
		respond_to do |format|
			parametros = estudante_params
			nome_instituicao = parametros[:instituicao_ensino_nome]
			if nome_instituicao  # executado somente para edição dos dados cadastrais, quando o campo instituicao_ensino_nome está presente
				cidade_id = estudante_params[:instituicao_ensino_cidade_id]
				@instituicao = InstituicaoEnsino.where(nome: nome_instituicao, cidade_id: cidade_id).first_or_create do |instituicao|
					instituicao.nome = nome_instituicao
					instituicao.cidade_id = cidade_id
				end
				parametros[:instituicao_ensino_id] = @instituicao.id if @instituicao.valid? 
			end

			if current_estudante.update(parametros)
				format.html{ redirect_to current_estudante, notice: "Dados salvos com sucesso!" }
			else
				@estudante_errors = current_estudante.errors.full_messages.to_s
				format.html{redirect_to current_estudante, alert: @estudante_errors }
			end
		end
	end

	def update_password
		@estudante = Estudante.find(current_estudante.id)
    	if @estudante.update(estudante_params)
	      # Sign in the user by passing validation in case their password changed
	      sign_in @estudante, :bypass => true
	      flash[:notice] = "Dados salvos com sucesso!"
	      redirect_to current_estudante
    	else
     	  flash[:alert] = "Ocorreu um erro."
		  redirect_to current_estudante
    	end
	end

	private
		def estudante_params
			params.require(:estudante).permit(:nome, :cpf, :rg, :data_nascimento, :sexo, :telefone,
											  :logradouro, :complemento, :setor, :cep, :cidade_id, :uf,
											  :instituicao_ensino_id, :curso_id, :matricula, :foto, 
											  :comprovante_matricula, :xerox_rg, :email, :password, 
											  :celular, :numero, :expedidor_rg, :uf_expedidor_rg, 
											  :callback, :xerox_cpf, :entidade_id, :instituicao_ensino_nome,
											  :instituicao_ensino_cidade_id)
		end
end