class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
  
  belongs_to :cidade
  has_one :estado, through: :cidade
  has_many :carteirinhas
  has_many :estudantes
  belongs_to :entidade
  has_many :certificado_pedidos

  # expressões regulares
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  STRING_REGEX = /\A[a-z A-Z]+\z/
  LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

  enum status: {ativo: "1", inativo: "0"}
  enum super_admin: {sim: "1", nao: "0"}

  #validações
  validates :nome, length: {maximum: 70, too_long: "Máximo de %{count} caracteres permitidos!"}, 
                         format:{with: LETRAS, message:"Somente letras é permitido!"}, allow_blank: false
  validates :email, uniqueness: {message: "Email já utilizado!"}, format: {with: EMAIL_REGEX , on: :create}
  validates :sexo, inclusion:{in: %w(Masculino Feminino), message: "%{value} não é um gênero válido."}, allow_blank: true
  validates :usuario,  uniqueness: {message: "Usuário já utilizado!"} ,presence: true, length:{in: 6..10, wrong_length: "Tamanho errado %{count}"}
  validates :expedidor_rg, length:{maximum: 10, too_long:"Máximo de 10 caracteres permitidos!"}, 
               format:{with:STRING_REGEX, message: "Somente letras é permitido!"}, allow_blank: true
  validates :uf_expedidor_rg, length:{is: 2}, format:{with:STRING_REGEX}, allow_blank: true
  validates :saldo, numericality:true, allow_blank: true
  validates :telefone, length:{in: 10..11}, numericality: true, allow_blank: true
  validates :logradouro, length:{maximum: 50}, allow_blank: true
  validates :complemento, length:{maximum: 50}, allow_blank: true
  validates :setor, length:{maximum: 50}, allow_blank: true
  validates :cep, length:{is: 8}, numericality: true, allow_blank: true
  validates :cidade, length:{maximum: 30, too_long:"Máximo de 70 carectetes é permitidos!"}, allow_blank: true
  validates :celular, length:{in: 10..11}, numericality: true, allow_blank: true
  validates :numero, length:{maximum: 5}, numericality: true, allow_blank: true
  validates :rg, numericality: true, allow_blank: true
  validates :cpf, numericality: true, length:{is: 11, too_long: "Necessário 11 caracteres.",  too_short: "Necessário 11 caracteres."}, allow_blank: true
  validates :setor, length: { maximum: 30, too_long: "Máximo de 30 caracteres permitidos!"}, allow_blank: true
  validates :valor_certificado, numericality: true, allow_blank: false, presence: true

  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true

  before_create :reset_password
  before_update :reset_password

  def entidade_nome
    self.entidade.nome if self.entidade
  end

  def cidade_nome
    self.cidade.nome if self.cidade
  end

  def uf_nome
    estado = self.cidade.estado if self.cidade
    nome_estado = estado.sigla if estado
  end

  def nome_pagamento
    prefix = ''
    if(self.entidade && self.entidade.sigla)
      prefix = "#{self.entidade.sigla}"
    else
      prefix = "#{self.entidade.nome}"
    end
    "#{prefix}: #{self.nome}"
  end

  def uf
  end

  def estado_id
    estado = self.cidade.estado if self.cidade
    estado.id if estado
  end

  def reset_password
    self.password = Devise.friendly_token if self.inativo?
  end

  def saldo_carteiras
    (self.saldo/self.valor_certificado).to_i
  end

  def show_no_menu?
    if self.valor_certificado && self.valor_certificado > 0
      return true
    end
    if !self.entidade || self.sim? 
      return true
    end
    return false
  end

  private    
    def password_required?
      new_record? ? super : false
    end  

end