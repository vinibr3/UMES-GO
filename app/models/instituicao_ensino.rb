class InstituicaoEnsino < ActiveRecord::Base
  
  belongs_to :cidade
  has_many :estudantes
  has_many :cursos
  has_one :estado, through: :cidade

  STRING_REGEX = /\A[a-z A-Z]+\z/
  LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/ #/[[:alpha:]]/ #/[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/ 

  validates :nome, length: { maximum: 200, too_long: "Máximo de 100 caracteres permitidos!"}, 
	                 		   format:{with: LETRAS, message:"Somente letras é permitido!"},
	                 		   allow_blank: false
  validates :sigla, length: {maximum: 10, too_long: "Máximo de #{count} caracteres permitidos."},
					  format: {with: STRING_REGEX, message: "Somente letras é permitido"}, allow_blank: true
  validates :cnpj, numericality: true, length: {is: 14, wrong_length: "14 caracteres."}, allow_blank: true				  
  validates :logradouro, length:{maximum: 50}, allow_blank: true
  validates :complemento, length:{maximum: 50}, allow_blank: true
  validates :numero, length:{maximum: 5}, numericality: true, allow_blank: true
  validates :cep, length:{is: 8, wrong_length: "#{count} caracteres."}, numericality: true, allow_blank: true

  before_save :to_upcase
  before_create :to_upcase
  before_update :to_upcase
  
  def self.cursos
    self.instituicao_ensino_cursos.cursos
  end

  def self.escolaridades
    self.cursos.escolaridades
  end

  def entidade_nome
    self.entidade.nome if self.entidade
  end

  def to_upcase
    self.nome = self.nome.mb_chars.upcase if self.nome
  end

  def cidade_nome
    self.cidade.nome if self.cidade
  end

  def cidade_id
    self.cidade.id if self.cidade
  end

  def estado_sigla 
    self.estado.sigla if self.estado
  end

  def estado_nome
    self.estado.nome if self.estado
  end

  def estado_id
    self.estado.id if self.estado
  end

  def nome_autocomplete 
    nome = self.nome
    cidade = self.cidade
    if cidade
      nome  = "#{nome}, #{self.cidade.nome.mb_chars.upcase}"
      nome = "#{nome} - #{cidade.estado.sigla.upcase}" if cidade.estado
    end
    nome
  end

end