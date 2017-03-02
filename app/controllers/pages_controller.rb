class PagesController < ApplicationController
  
  def index
  	 @avisos = Aviso.all
     @eventos = Evento.all
     @noticias = Noticia.order(:created_at).last(2)
  end

  def sobre

  end

  def meia_entrada

  end

  def noticias 

  end

  def consulta
    
  end

private
  def page_params
    params.require(:page_params).permit(:codigo_uso)
  end

end