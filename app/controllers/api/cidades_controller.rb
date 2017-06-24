class Api::CidadesController < Api::AuthenticateBase
	before_action :http_base_authentication

	def index
		@estado = Estado.find_by_sigla(params[:estado_uf])
		respond_with @estado.cidades if @estado
	end

	def show
		@estado = Estado.find_by_sigla(params[:estado_uf])
		@cidade = @estado.cidades.where(nome: params[:nome]).first if @estado
		respond_with @cidade if @cidade 
	end
end