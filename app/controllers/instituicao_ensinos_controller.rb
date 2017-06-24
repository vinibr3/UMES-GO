class InstituicaoEnsinosController < ApplicationController
	before_action :authenticate_estudante!
	def index
		param = I18n.transliterate(params[:term].mb_chars.upcase)
		instituicoes = InstituicaoEnsino.order(:nome).where("unaccent(upper(nome)) ILIKE ?", "%#{param}%").limit(50)
		render json: instituicoes.map{|i| {id: i.id, value: i.nome, label: i.nome_autocomplete, uf_id: i.estado_id, cidade_id: i.cidade_id}}, root: false
	end
end