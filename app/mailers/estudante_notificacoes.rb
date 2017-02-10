class EstudanteNotificacoes < ApplicationMailer
	
	def status_notificacoes carteirinha
		@carteirinha = carteirinha
		@estudante = carteirinha.estudante
		@entidade = Entidade.instance
		mail(:to => @estudante.email, :subject => "Solicitação de CIE")
	end

	def create_notificacoes estudante
		@estudante = estudante
		@entidade = Entidade.first
		mail(:to => @estudante.email, :subject => "Cadastro")
	end

end
