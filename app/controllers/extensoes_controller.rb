class ExtensoesController < ApplicationController
	# Retorna a Lista de Certificados Revogados (CRL)
	def crl 
		@extensao = Extensao.where(entidade_id: params[:entidade_id], id: params[:id]).first
		if request.format.crl? && @extensao
			redirect_to @extensao.lista_certificados_revogados.url
		else
			render nothing: true
		end
	end

	# Retorna a Cadeia de Certificados Raiz (Authority Information Access)
	def aia
		@extensao = Extensao.where(entidade_id: params[:entidade_id], id: params[:id]).first
		if request.format.p7b? && @extensao
			redirect_to @extensao.cadeia_certificados_raiz.url
		else
			render nothing: true
		end
	end
end
