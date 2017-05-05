class Estudante < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
	
	has_many :carteirinhas
	belongs_to :entidade
	belongs_to :instituicao_ensino
	belongs_to :curso
	belongs_to :cidade
	belongs_to :admin_user
	has_one :estado, through: :cidade
	has_one :escolaridade, through: :curso

	url_path = "/default/:class/:id/:attachment/:style/:filename"

	has_attached_file :foto, :styles => {:original => {}}
	has_attached_file :comprovante_matricula, :styles => {:original => {}}, :path => "#{url_path}"
	has_attached_file :xerox_rg, :styles => {:original => {}}, :path => "#{url_path}"
	has_attached_file :xerox_cpf, :styles => {:original => {}}, :path => "#{url_path}"
	
	FILES_NAME_PERMIT = [/png\Z/, /jpe?g\Z/, /pdf\Z/]
	FILES_CONTENT_TYPE = ['image/jpeg', 'image/png', 'application/pdf']

	# expressões regulares
	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
	STRING_REGEX = /\A[a-z A-Z]+\z/
	LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

	@@GENEROS = %w(Masculino Feminino)

	before_create :create_oauth_token, :create_chave_acesso

	# validações
	validates :nome, length: { maximum: 100, too_long: "Máximo de 100 caracteres permitidos!"}, 
	                 format:{with: LETRAS, message:"Somente letras é permitido!"}, allow_blank: true
	validates :email, uniqueness: true, format: {with: EMAIL_REGEX , on: :create}
	validates :sexo, inclusion: @@GENEROS, allow_blank: true
	validates :telefone, length:{in: 10..11}, numericality: true, allow_blank: true
	validates :logradouro, length:{maximum: 50}, allow_blank: true
	validates :complemento, length:{maximum: 50}, allow_blank: true
	validates :setor, length:{maximum: 50}, allow_blank: true
	validates :cep, length:{is: 8}, numericality: true, allow_blank: true
	validates :cidade, length:{maximum: 30, too_long:"Máximo de 70 carectetes é permitidos!"}, format:{with: LETRAS}, allow_blank: true
	validates :matricula, numericality: true, length:{maximum: 50}, allow_blank: true
	validates :celular, length:{in: 10..11}, numericality: true, allow_blank: true
	validates :numero, length:{maximum: 5}, numericality: true, allow_blank: true
	validates :rg, numericality: { only_integer: true }, allow_blank: true
	validates :cpf, numericality: true, length:{is: 11, too_long: "Necessário 11 caracteres.",  too_short: "Necessário 11 caracteres."}, allow_blank: true
	validates :expedidor_rg, length:{maximum: 10, too_long:"Máximo de 10 caracteres permitidos!"}, 
							 format:{with:STRING_REGEX, message: "Somente letras é permitido!"}, allow_blank: true
	validates :uf_expedidor_rg, length:{is: 2}, format:{with:STRING_REGEX}, allow_blank: true
	validates :chave_acesso, length:{is: 10, too_long: "Necessário 10 caracteres", too_short: "Necessário 10 caracteres"}, allow_blank: true
	validates_attachment_size :foto, :less_than => 1.megabytes
	validates_attachment_size :xerox_rg, :less_than => 1.megabytes
	validates_attachment_size :comprovante_matricula, :less_than => 1.megabytes
	validates_attachment_size :xerox_cpf, :less_than => 1.megabytes
	validates_attachment_file_name :foto, :matches => [/png\Z/, /jpe?g\Z/]
	validates_attachment_file_name :comprovante_matricula, :matches=> FILES_NAME_PERMIT
	validates_attachment_file_name :xerox_rg, :matches => FILES_NAME_PERMIT
	validates_attachment_file_name :xerox_cpf, :matches => FILES_NAME_PERMIT
	validates_attachment_content_type :foto, :content_type=> ['image/png', 'image/jpeg']
	validates_attachment_content_type :comprovante_matricula, :content_type=> FILES_CONTENT_TYPE
	validates_attachment_content_type :xerox_rg, :content_type=> FILES_CONTENT_TYPE
	validates_attachment_content_type :xerox_cpf, :content_type=> FILES_CONTENT_TYPE
	validates_acceptance_of :termos
    
    validates_length_of :foto_file_name, :comprovante_matricula_file_name, :xerox_rg_file_name, :maximum => 50, :message => "Nome do arquivo deve ser menor que %{count} caracteres"

	public
		def tem_carteirinha
			!self.carteirinha.last.nil?
		end

		def email_less_domain 
			string_to_substring(self.email, '@')
		end

		def first_name 
			string_to_substring(self.nome, " ")
		end
		
	def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |estudante|
			estudante.provider = auth.provider
			estudante.uid = auth.uid
			estudante.nome = auth.info.name
			estudante.email = auth.info.email
			#estudante.sexo = auth.extra.gender.slice(0).captalize unless auth.extra.gender != ('male'||'female')
			estudante.password = Devise.friendly_token
		end
	end

	def self.new_with_session(params, session)
		if session["devise.estudante_attributes"]
			new(session["devise.estudante_attributes"], without_protection: true) do |estudante|
				estudante.attributes = params
				estudante.valid?
			end
		else
			super
		end	
	end

	def last_valid_carteirinha
	 	cart = self.carteirinhas.last
	 	if !cart.nil?
	 		cart.valid ? cart : nil
	 	end
	 	cart 
	end

	def self.koala(access_token)
		facebook = Koala::Facebook::API.new(access_token, ENV['MOBILEAPP_FACEBOOK_APP_SECRET'])
		auth = facebook.get_object("me?fields=id,name,email,birthday,gender,location,education")
	end

	def self.from_koala(auth)
		where(email: auth["email"]).first_or_create do |estudante|
			estudante.uid = auth["id"] if auth.has_key?('id')
			estudante.email = auth["email"] if auth.has_key?('email')
			estudante.nome = auth["name"] if auth.has_key?('name') 
			estudante.data_nascimento = config_date(auth["birthday"]) if auth.has_key?('birthday')
			estudante.sexo =  auth["gender"].slice(0).upcase if auth["gender"] == ('female' || 'male')
			estudante.provider = 'facebook' 
			estudante.cidade = auth["location"]['name'] if auth.has_key?('location')
			estudante.instituicao_ensino = education_last(auth["education"]) if auth.has_key?('education')
			estudante.password = Devise.friendly_token
		end
	end

	def self.first_or_create_from_koala(access_token)
		auth = koala(access_token)
		estudante = from_koala(auth)
	end

	def config_date(auth)
		birthday = auth.gsub('/','-') 
		birthday = Date.strptime(birthday, '%m-%d-%Y').to_time
	end

	def education_last(education)
			array = education.to_a
			array[array.length-1]["name"]
	end

	def dados_pessoais
		array = Array.new
		array << self.data_nascimento
		array << self.cpf
		array << self.matricula
		array << self.rg_certidao
		array
	end

	def dados_estudantis
		array = Array.new
		array << self.instituicao_ensino
		array << self.periodo
		array << self.curso_serie
		array << self.instituicao_ensino.cidade.nome if self.instituicao_ensino && self.instituicao_ensino.cidade
		array << self.instituicao_ensino.cidade.estado.nome if self.instituicao_ensino && 
																												self.instituicao_ensino.cidade && 
																												self.instituicao_ensino.cidade.estado
		array
	end

	def atributos_nao_preenchidos
		nao_preenchidos = Array.new
		atributos = {:nome=>"Nome", :email =>"Email", :cpf=>"CPF", :rg=>"RG", :expedidor_rg=>"Expedidor RG", 
								 :uf_expedidor_rg=>"UF Expedidor RG", :data_nascimento => "Data de Nascimento", :sexo=> "Sexo", 
								 :celular=>"Celular", :logradouro=>"Logradouro", :numero =>"Número", :cep =>"CEP", 
								 :cidade_id=>"Cidade", :instituicao_ensino_id=>"Instituição de Ensino", :curso_id =>"Curso",
			           :matricula=>"Matrícula", :foto_file_name =>"Foto", :comprovante_matricula_file_name=>"Comprovante de matrícula", 
			           :xerox_rg_file_name=>"Xerox RG", :xerox_cpf_file_name=>"Xerox CPF", :entidade_id=>"Entidade"}
		atributos.keys.each do |key|
			nao_preenchidos << atributos[key] if self[key].blank?
		end
		nao_preenchidos
	end

	def confirmation_required?
		self.provider.blank?
	end

	def curso_nome
		self.curso.nome if self.curso
	end

	def escolaridade_nome
		self.curso.escolaridade_nome if self.curso
	end

	def escolaridade_id
		escolaridade = self.curso.escolaridade if self.curso
		escolaridade.id if escolaridade
	end

	def instituicao_ensino_nome
		self.instituicao_ensino.nome if self.instituicao_ensino
	end

	def cidade_nome
		self.cidade.nome if self.cidade
	end

	def estado_nome
		estado = self.cidade.estado if self.cidade
		estado.nome if estado
	end

	def estado_id
		estado = self.cidade.estado if self.cidade
		estado.id if estado
	end

	def estado_sigla
		estado = self.cidade.estado if self.cidade
		estado.sigla if estado
	end

	def entidade_nome
		self.entidade.nome if self.entidade
	end

	def instituicao_ensino_nome
		self.instituicao_ensino.nome if self.instituicao_ensino
	end

	def instituicao_ensino_nome=(nome)
		nome = nome.mb_chars.upcase
		instituicao = InstituicaoEnsino.find_by_nome(nome)
		if instituicao
			self.instituicao_ensino = instituicao
		else
			instituicao = InstituicaoEnsino.new(nome: nome)
			if instituicao.valid?
				instituicao.save
				instituicao = InstituicaoEnsino.find_by_nome(nome)
				self.instituicao_ensino = instituicao
			end
		end
	end

	protected
		def endereco
	 		endereco = Hash.new
	 		endereco['logradouro'] = self[:logradouro]
	 		endereco['numero'] = self[:numero].to_i
	 		endereco['complemento'] = self[:complemento]
	 		endereco['cidade'] = self[:cidade]
	 		endereco['cep'] = self[:cep].to_i
	 		endereco['uf'] = self[:cidade].estado.nome if self[:cidade] && self[:cidade].estado
	 		endereco
	 	end

	private
		def string_to_substring(string , char)
			string.split(char).first
		end

		def create_oauth_token
			begin
				self.oauth_token = Devise.friendly_token
			end while self.class.exists?(oauth_token: oauth_token)
		end

		def create_chave_acesso
			self[:chave_acesso] = SecureRandom.hex(5).upcase
		end

end