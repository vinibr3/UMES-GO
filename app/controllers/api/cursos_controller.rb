class Api::CursosController < Api::AuthenticateBase
	before_action :http_base_authentication
	def index
		@escolaridade = Escolaridade.find(params[:escolaridade_id])
		respond_with @escolaridade.cursos.order(:nome)
	end
end