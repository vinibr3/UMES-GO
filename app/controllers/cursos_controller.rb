class CursosController < ApplicationController
	def show 
		@param = params[:escolaridade_id]
		@escolaridade = nil
		@cursos_maped = nil
		if @param.match(/[0-9]+/) # busca pelo id
			@escolaridade = Escolaridade.find(@param)
			@cursos = @escolaridade.cursos.order(:nome).where(status: "1") if @escolaridade
			@cursos_maped = @cursos.map{|c| [c.nome.mb_chars.upcase, c.id]}
		else # busca pelo nome
			@escolaridade = Escolaridade.find_by_nome(@param)
			@cursos = @escolaridade.cursos.order(:nome).where(status: "1") if @escolaridade
			@cursos_maped = @cursos.map(&:nome)
		end
		respond_to do |format|
			format.js
		end
	end
end
