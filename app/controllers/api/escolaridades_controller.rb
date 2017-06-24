class Api::EscolaridadesController < Api::AuthenticateBase 
	before_action :http_base_authentication
	def index
		@escolaridades = Escolaridade.where(status: "1").order(:nome)
		respond_with @escolaridades
	end
end