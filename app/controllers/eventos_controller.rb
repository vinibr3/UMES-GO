class EventosController < ApplicationController

	def index
		@avisos = Aviso.all
		@eventos = Evento.all
	end

	def show
		@evento = Evento.find(params[:id])
		@eventos = Evento.all
		@avisos = Aviso.all
	end

end
