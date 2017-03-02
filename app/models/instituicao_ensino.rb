class InstituicaoEnsino < ActiveRecord::Base
  
  belongs_to :cidade
  belongs_to :estado
  has_many :estudantes
  has_many :cursos

  STRING_REGEX = /\A[a-z A-Z]+\z/
  LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

  validates :nome, length: { maximum: 100, too_long: "Máximo de 100 caracteres permitidos!"}, 
	                 		   format:{with: LETRAS, message:"Somente letras é permitido!"},
	                 		   allow_blank: false
  validates :sigla, length: {maximum: 10, too_long: "Máximo de #{count} caracteres permitidos."},
					  format: {with: STRING_REGEX, message: "Somente letras é permitido"}, allow_blank: false
  validates :cnpj, numericality: true, length: {is: 14, wrong_length: "14 caracteres."}, allow_blank: true				  
  validates :logradouro, length:{maximum: 50}, allow_blank: true
  validates :complemento, length:{maximum: 50}, allow_blank: true
  validates :numero, length:{maximum: 5}, numericality: true, allow_blank: true
  validates :cep, length:{is: 8, wrong_length: "#{count} caracteres."}, numericality: true, allow_blank: true
  validates_presence_of :cidade

  before_save :to_upcase
  
  def self.cursos
    self.instituicao_ensino_cursos.cursos
  end

  def self.escolaridades
    cursos.escolaridades
  end

  def entidade_nome
    self.entidade.nome if self.entidade
  end

  def to_upcase
    self.nome = self.nome.upcase
  end

  def cidade_nome
    self.cidade.nome if self.cidade
  end

  def estado_sigla 
    self.estado.sigla if self.estado
  end

  def estado_id
    self.estado.id if estado
  end

end

