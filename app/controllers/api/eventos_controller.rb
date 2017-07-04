class Api::EventosController < Api::AuthenticateBase
	before_action :http_base_authentication
	def index
		@eventos = Evento.all
		respond_with @eventos
	end
end