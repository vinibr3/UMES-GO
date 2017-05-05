class InstituicaoEnsinosController < ApplicationController
	before_action :authenticate_estudante!
	def index
		param = I18n.transliterate(params[:term].mb_chars.upcase)
		instituicoes = InstituicaoEnsino.order(:nome).where("unaccent(upper(nome)) LIKE ?", "%#{param}%").limit(10)
		render json: instituicoes.map(&:nome), root: false
	end
end
