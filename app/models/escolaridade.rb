class Escolaridade < ActiveRecord::Base
	has_many :cursos

	before_save :upcase_all
	before_create :set_status

	LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

	validates :nome, length:{maximum: 70, too_long: "Máximo de 70 caracteres permitidos!"},
							format:{with: LETRAS, message:"Somente letras é permitido"}, presence: true
	
	enum status: { ativo: '1', inativo: '0' }
	
	def upcase_all
		self[:nome].upcase
	end

	def set_status
		self[:status] = '1'
	end

	def self.escolaridades
		order(:nome).where(status: "1")
	end

	def self.cursos id
		escolaridade = find id
		escolaridade.cursos if escolaridade.cursos
	end

end