class Api::AvisosController < Api::AuthenticateBase
	before_action :http_base_authentication
	def index
		@avisos = Aviso.all.order(:created_at)
		respond_with @avisos
	end	
end