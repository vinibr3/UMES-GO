class Escolaridade < ActiveRecord::Base
	has_many :cursos

	before_save :upcase_all
	before_create :set_status

	STRING_REGEX = /\A[a-z A-Z]+\z/

	validates :nome, length:{maximum: 70, too_long: "Máximo de 70 caracteres permitidos!"},
							format:{with: STRING_REGEX, message:"Somente letras é permitido"}, presence: true
	
	enum status: { ativo: '1', inativo: '0' }
	
	def upcase_all
		self[:nome].upcase
	end

	def set_status
		self[:status] = '1'
	end

	def self.escolaridades
		where(status: "1")
	end

	def self.cursos id
		escolaridade = find id
		escolaridade.cursos if escolaridade.cursos
	end

end