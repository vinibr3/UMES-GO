class NoticiasController < ApplicationController
  def index
  	@noticias = Noticia.all
  	@eventos = Evento.all
  	@avisos = Aviso.all
  end

  def show
  	@noticia = Noticia.find(params[:id])
  	@eventos = Evento.all
  	@avisos = Aviso.all
  end
end
