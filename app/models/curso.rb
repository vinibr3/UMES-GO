class Curso < ActiveRecord::Base
	has_many :estudante
	belongs_to :escolaridade
	#belongs_to :instituicao_ensino
	
	LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ]+/

	before_create :set_status

	enum status: {ativo: '1', inativo: '0'}

	validates :nome, length:{maximum: 200, too_long: "Máximo de 100 caracteres permitidos!."}, format:{with: LETRAS}, allow_blank: true
	#validates_associated :escolaridade
	validates_presence_of :nome, :escolaridade     

	before_save :upcase_all
	before_create :upcase_all
	before_update :upcase_all

	def upcase_all
		self.nome = self.nome.mb_chars.upcase if self.nome 
	end

	def escolaridade_nome
		self.escolaridade.nome if self.escolaridade
	end
	
	def self.cursos
		order(:nome).where(status: "1")
	end

	private 
		def set_status
			self[:status] = '1'
		end

end
