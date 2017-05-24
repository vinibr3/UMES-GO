class Entidade < ActiveRecord::Base
	
	url_path = "/admin/:class/:id/:attachment/:style/:filename"

	has_attached_file :logo, :styles => {:original => {}}, :path => "#{url_path}"
	has_attached_file :configuracao, :styles => {:original => {}}
	
	has_many :estudantes
	has_many :carteirinhas, through: :estudantes
	has_many :layout_carteirinhas
	has_many :instituicao_ensinos
	has_many :extensoes

	FILES_NAME_PERMIT = [/png\Z/, /jpe?g\Z/]
	FILES_CONTENT_TYPE = ['image/jpeg', 'image/png']

	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
	STRING_REGEX = /\A[a-z A-Z]+\z/
	LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

	#dados entidade
	validates :nome, length: { maximum: 70, too_long: "Máximo de #{count} caracteres permitidos."}, 
	                 format: {with: LETRAS, message:"Somente letras é permitidos."}, allow_blank: false
	validates :sigla, length: {maximum: 10, too_long: "Máximo de #{count} caracteres permitidos."},
					  format: {with: STRING_REGEX, message: "Somente letras é permitido"}, allow_blank: false				  
	validates :email, uniqueness: {message: "Email já utilizado"}, format: {with: EMAIL_REGEX, on: :create}
	validates :cnpj, numericality: true, length: {is: 14, wrong_length: "14 caracteres."}, allow_blank: true
	validates :valor_carteirinha, numericality: true, allow_blank: false
	validates :frete_carteirinha, numericality: true, allow_blank: true
	validates :telefone, numericality: true, length: {in: 10..11, wrong_format: "Mínimo de 10 e máximo 11 caracteres permitidos."}, allow_blank: true
    validates :logradouro, length:{maximum: 50, too_long:"Máximo de #{count} caracteres permitidos."}, allow_blank: true
    validates :numero, numericality: true, length: {maximum: 10, too_long: "Máximo de #{count} caracteres permitidos."}, allow_blank: true  
    validates :complemento, length: {maximum: 50, too_long: "Máximo de #{count} caracteres permitidos."}, allow_blank: true
	validates :setor, length: {maximum: 30,too_long: "Máximo de #{count} caracteres permitidos."}, allow_blank: true
	validates :cep, length:{is: 8, wrong_length: "#{count} caracteres."}, numericality: true, allow_blank: true
	validates :cidade, length: {maximum: 50, too_long: "Máximo de #{count} caracteres permitidos."}, allow_blank: true
	validates :uf, length: {is: 2, wrong_length: "Máximo de 2 caracteres permitidos."}, format: {with: STRING_REGEX}, allow_blank: true
	validates :url_qr_code, length: {maximum: 300, too_long: "Máximo de #{count} caracteres permitidos."}, format:{with: URI.regexp} ,allow_blank: false
	#validates :auth_info_access, length:{maximum: 100, too_long: "Máximo de #{count} caracteres permitidos."}, format:{with: URI.regexp}, allow_blank: false
	#validates :crl_dist_points, length:{maximum: 100, too_long: "Máximo de #{count} caracteres permitidos."}, format:{with: URI.regexp}, allow_blank: false
	validates :dominio, length:{maximum: 300, too_long: "Máximo de #{count} caracteres permitidos."}, format:{with: URI.regexp}, allow_blank: false
	validates_attachment_size :logo, :less_than => 1.megabytes
	validates_attachment_file_name :logo, :matches => FILES_NAME_PERMIT
	validates_attachment_content_type :logo, :content_type => FILES_CONTENT_TYPE
	
	#dados presidente da entidade
	validates :nome_presidente, length: { maximum: 70, too_long: "Máximo de #{count} caracteres permitidos!"}, 
	                 format: {with: LETRAS, message:"Somente letras é permitido!"}
	validates :email_presidente, uniqueness: {message: "Email já utilizado"}, format: {with: EMAIL_REGEX, on: :create}
	validates :cpf_presidente, numericality: true, length:{is: 11, wrong_length: "Necessário 11 caracteres."}, allow_blank: true
	validates :rg_presidente, numericality: true, allow_blank: true
	validates :expedidor_rg_presidente, length:{maximum: 10, too_long:"Máximo de #{count} caracteres permitidos!"}, 
							 format:{with: STRING_REGEX, message: "Somente letras é permitido!"}, allow_blank: true
	validates :uf_expedidor_rg_presidente, length:{is: 2, wrong_message: "#{count} caracteres permitidos."}, format:{with:STRING_REGEX}, allow_blank: true
	validates :celular_presidente, length:{in: 10..11}, numericality: true, allow_blank: true
	validates :telefone_presidente, length:{in: 10..11}, numericality: true, allow_blank: true
	validates :sexo_presidente, inclusion: %w(Masculino Feminino), allow_blank: true
	validates :complemento_presidente, length: {maximum: 50, too_long:"Máximo de #{count} caracteres permitidos."}, allow_blank: true
	validates :logradouro_presidente, length:{maximum: 50, too_long:"Máximo de #{count} caracteres permitidos."}, allow_blank: true
	validates :numero_presidente, numericality: true, length: {maximum: 10, too_long: "Máximo de #{count} caracteres permitidos."}, allow_blank: true  	
	validates :cep_presidente, length:{is: 8, wrong_length: "8 caracteres."}, numericality: true, allow_blank: true
	validates :cidade_presidente, length: {maximum: 50, too_long: "Máximo de #{count} caracteres permitidos."}, allow_blank: true
	validates :uf_presidente, length: {is: 2, wrong_length: "Máximo de 2 caracteres permitidos."}, format: {with: STRING_REGEX}, allow_blank: true

	validates_presence_of :nome, :sigla, :email, :valor_carteirinha, :dominio, :url_qr_code 

	before_create :config_data_from_dominio

	def self.instance
		entidade = Entidade.first
		if entidade 
		   return entidade
		else
			raise "Nenhuma entidade Configurada"
		end
	end

	def self.entidade_padrao
		first
	end

	def self.cadeia_certificados_raiz_url id
		entidade = Entidade.find(id)
		if entidade 
			return entidade.cadeia_certificados_raiz_url
		else
			return self.entidade_padrao.cadeia_certificados_raiz_url if self.entidade_padrao
		end
	end

	def self.lista_certificados_revogados_url id
		entidade = Entidade.find(id)
		if entidade && entidade.has_cadeia_certificados_raiz?
			return entidade.lista_certificados_revogados_url
		else
			return self.entidade_padrao.lista_certificados_revogados_url if self.entidade_padrao
		end	
	end

	def layout_anverso
		self.layout_carteirinhas.first.anverso if self.layout_carteirinhas.first
	end

	def cadeia_certificados_raiz_url
		extensao = self.extensoes.last
		if extensao
			path = "#{build_url}/#{extensao.url_for_aia}"
			return "#{self.dominio}/#{path}"
		else
			nil
		end
	end

	def lista_certificados_revogados_url
		extensao = self.extensoes.last
		if extensao
			path = "#{build_url}/#{extensao.url_for_crl}"
			return "#{self.dominio}/#{path}"
		else
			nil
		end
	end

	def has_cadeia_certificados_raiz?
		self.extensoes.last
	end

	private 
		def config_data_from_dominio 
			self.usuario = self.sigla unless self.usuario
			self.token_certificado = Devise.friendly_token unless self.token_certificado 
		end

		def build_url
			"entidades/#{self.id}"
		end
end