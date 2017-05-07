class Cidade < ActiveRecord::Base
  belongs_to :estado
  has_many :admin_user
  has_many :estudante

  LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/
 
  validates_presence_of :nome
  validates_format_of :nome, with: LETRAS, message: "Formato inválido"
  validates_length_of :nome, in: 1..40, wrong_length: "Mínimo de 1 e máximo de 40"
  validates_uniqueness_of :nome

  def estado_nome
  	self.estado.nome if self.estado
  end

  def estado_id
  	self.estado.id if self.estado
  end

  def estado_sigla
  	self.estado.sigla if self.estado
  end

end