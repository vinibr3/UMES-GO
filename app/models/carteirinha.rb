class Carteirinha < ActiveRecord::Base

	belongs_to :estudante
	belongs_to :entidade
	belongs_to :layout_carteirinha
	belongs_to :admin_user

	url_path = "/default/:class/:id/:attachment/:style/:filename"

	has_attached_file :foto, :styles => {:original => {}}, :path => "#{url_path}"
	has_attached_file :xerox_cpf, :styles => {:original => {}}, :path => "#{url_path}"
	has_attached_file :xerox_rg, :styles => {:original => {}}, :path => "#{url_path}"
	has_attached_file :comprovante_matricula, :styles => {:original => {}}, :path => "#{url_path}"

	FILES_NAME_PERMIT = [/png\Z/, /jpe?g\Z/, /pdf\Z/]
	FILES_CONTENT_TYPE = ['image/jpeg', 'image/png', 'application/pdf']

	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
	STRING_REGEX = /\A[a-z A-Z]+\z/
	LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

	@@status_versao_impressas = {pagamento: "Pagamento", documentacao: "Documentação", aprovada: "Aprovada", 
								   					   enviada: "Enviada", entregue: "Entregue", cancelada: "Cancelada", revogada: "Revogada"}

	@@forma_pagamentos = {cartao_de_credito: "Cartão de crédito", boleto: "Boleto", a_definir: "A definir",
										    debito_online: "Débito online", saldo_pagseguro: "Saldo PagSeguro", 
										    oi_pago: "Oi Paggo", deposito_em_conta: "Depósito em conta", dinheiro: "Dinheiro"}		   				

	@@status_pagamentos = {iniciado: "Iniciado", aguardando_pagamento: "Aguardando pagamento", em_analise: "Em análise",
							 				   pago: "Pago", disponivel: "Disponível", em_disputa: "Em disputa", devolvido: "Devolvido",
							 				   cancelado: "Cancelado", contestado: "Contestado"}

	enum status_versao_impressa: @@status_versao_impressas
	enum forma_pagamento: @@forma_pagamentos
	enum status_pagamento: @@status_pagamentos

	# validações
	validates :nome, length: { maximum: 70, too_long: "Máximo de 70 caracteres permitidos"}, format:{with: LETRAS, message:"Somente letras é permitido!"}
	validates :instituicao_ensino, length:{maximum: 50}
	validates :curso_serie, length:{maximum: 70}
	validates :matricula, numericality: true, length:{maximum: 30}, allow_blank: true
	validates :rg, numericality: {only_integer: true}
	validates :instituicao_ensino, length:{maximum: 50, too_long: "Máximo de 50 caracteres permitidos!."}, format: {with: LETRAS}, allow_blank: true
	validates :cidade_inst_ensino, length:{maximum: 30, too_long:"Máximo de 70 carectetes é permitidos!"}, format:{with: LETRAS}, allow_blank: true
	validates :curso_serie, length:{maximum: 40, too_long: "Máximo de 40 caracteres permitidos!."}, format:{with: LETRAS}, allow_blank: true
	validates :termos, acceptance: true
	validates :numero_serie, numericality: true, uniqueness: true, allow_blank: true
	validates :cpf, numericality: true, length:{is: 11, too_long: "Necessário 11 caracteres.",  too_short: "Necessário 11 caracteres."}, allow_blank: true
	validates :expedidor_rg, length:{maximum: 10, too_long:"Máximo de 10 caracteres permitidos!"}, 
							 						 format:{with:STRING_REGEX, message: "Somente letras é permitido!"}, allow_blank: true
	validates :uf_expedidor_rg, length:{is: 2}, format:{with:STRING_REGEX}, allow_blank: true
	validates :uf_inst_ensino, length:{is: 2}, format:{with:STRING_REGEX}, allow_blank: true
	validates :escolaridade, length:{maximum: 30, too_long: "Máximo de 30 caracteres permitidos!"},
							             format:{with:LETRAS, message:"Somente letras é permitido"}, allow_blank: true
	#foto
	validates_attachment_size :foto, :less_than => 1.megabytes
	validates_attachment_file_name :foto, :matches => [/png\Z/, /jpe?g\Z/]
	validates_attachment_content_type :foto, :content_type => ['image/jpeg', 'image/png', 'application/pdf']
	#xerox_rg
	validates_attachment_size :xerox_rg, :less_than => 1.megabytes
	validates_attachment_file_name :xerox_rg, :matches => FILES_NAME_PERMIT
	validates_attachment_content_type :xerox_rg, :content_type => FILES_CONTENT_TYPE
	#xerox_cpf
	validates_attachment_size :xerox_cpf, :less_than => 1.megabytes
	validates_attachment_file_name :xerox_cpf, :matches => FILES_NAME_PERMIT
	validates_attachment_content_type :xerox_cpf, :content_type => FILES_CONTENT_TYPE
	#comprovante_matricula
	validates_attachment_size :comprovante_matricula, :less_than => 1.megabytes
	validates_attachment_file_name :comprovante_matricula, :matches => FILES_NAME_PERMIT
	validates_attachment_content_type :comprovante_matricula, :content_type => FILES_CONTENT_TYPE

	validates_presence_of :estudante

	validate :so_muda_status_versao_impressa_se_pagamento_confirmado, :nao_avancar_status_se_dados_em_branco,
			 :check_status_carteirinha_apartir_status_pagamento

	before_update :gera_dados_se_carteirinha_aprovada, :muda_status_carteirinha_apartir_status_pagamento

	def dias_validade 
		nao_depois  = self.nao_depois
		seconds = nil
		dias = nil
		if nao_depois 
			seconds = self[:nao_depois] - Time.now.to_date
			dias = seconds*1000/24*60*60
		else
			dias = 1000;
		end
		dias.days
	end

	def valid
		dias_validade >= 0
	end

	def em_solicitacao?
		if valid
			if self.status_versao_impressa.aprovada?
				return false
			else
				return true
			end
		else
			return false
		end
	end

	def status_tag_versao_impressa
		status=""
		if self.status_versao_impressa_to_i <= 1
			status = :warning
		elsif self.status_versao_impressa_to_i >= 2 && self.status_versao_impressa_to_i <= 4 
			status = :ok
		elsif self.status_versao_impressa_to_i > 4 
			status = :error
		end
		status
	end

	def status_tag_status_pagamento
		status=""
		status_pgto_to_i = self.status_pagamento_to_i
		if status_pgto_to_i <= 2 
			status = :warning
		elsif status_pgto_to_i > 2 && status_pgto_to_i <= 4 
			status = :ok
		else status_pgto_to_i > 4 
			status = :error
		end
		status
	end

	def status_take_while
		index = self.status_versao_impressa_to_i+1
		statuses = @@status_versao_impressas.map{|k,v| v}
		statuses.take index
	end

	def solicitacao_cancelada_ou_revogada?
		self.status_versao_impressa == :cancelada || self.status_versao_impressa == :revogada
	end

	def so_muda_status_versao_impressa_se_pagamento_confirmado
		if self.status_pagamento_to_i < 3 # pagamento nao confirmado
			 errors.add(:status_versao_impressa, "pagamento da CIE não foi realizado") if status_versao_impressa_to_i >= 1
		end
	end

	def check_status_carteirinha_apartir_status_pagamento
		status_carteirinha = Carteirinha.show_status_carteirinha_apartir_do_status_pagamento self.status_pagamento
		status_carteirinha = status_carteirinha.map{|k,v| k}
		index = status_carteirinha.index(self.status_versao_impressa.to_sym)
		errors.add(:status_versao_impressa, "valor inválido para dado Status de Pagamento: #{self.status_pagamento.humanize} ") unless index
	end

	def nao_avancar_status_se_dados_em_branco
		if self.status_versao_impressa_to_i == 3 || self.status_versao_impressa_to_i == 4 # ENVIADA OU ENTREGUE
            variavel = [:nao_antes, :nao_depois, :codigo_uso, :qr_code, :certificado, 
            	        :numero_serie, :layout_carteirinha_id, :estudante_id]
            variavel.each do |v|
            	errors.add(v, "não pode ficar em branco") if self[v].blank? || self[v].nil?
            end
        end
	end

	def status_versao_impressa_to_i
		index=-1
		i=0
		@@status_versao_impressas.each_key do |key|
			index=i if key == self.status_versao_impressa.to_sym
			i=i+1
		end
		index
	end

	def status_pagamento_to_i
		Carteirinha.status_pagamento_to_i(self.status_pagamento)
	end

	def muda_status_carteirinha_apartir_status_pagamento
		#em processamento
		self.status_versao_impressa = :pagamento if status_pagamento_to_i <= 2
	end

	def self.status_pagamento_to_i status_pgto
		statuses = @@status_pagamentos.map{|k,v| k}
		statuses.index(status_pgto.to_sym)
	end

	def self.status_pagamento_by_code code
 		statuses = Carteirinha.status_pagamentos.map{|k,v| k}
 		if 1 < code.to_i && code.to_i < 7
 			return statuses[code.to_i]
 		else
 			return statuses[0] # Iniciado
 		end
 	end

	def self.forma_pagamento_by_type type
		formas = Carteirinha.forma_pagamentos.map{|k,v| k}
		forma = ''
		case type
		when "1" then forma = formas[0] # Cartão de Crédito
		when "2" then forma = formas[1] # Boleto
		when "3" then forma = formas[3] # Débito on-line
		when "4" then forma = formas[4] # Saldo Pag-seguro
		when "5" then forma = formas[5] # Oi pago
		when "7" then forma = formas[6] # Depósito em conta
		else forma = formas[2] # a definir
		end
		forma 
	end

	def self.show_status_carteirinha_apartir_do_status_pagamento status_pgto
		# Calcula status_pagamento_to_i
		status_pgto_to_i = Carteirinha.status_pagamento_to_i status_pgto
		status=[]
		if status_pgto_to_i <= 2  # iniciada, aguardando_pagamento, em_analise
			status = @@status_versao_impressas.select{|k,v| k == :pagamento} # somente pagamento 
		elsif status_pgto_to_i >=3 && status_pgto_to_i <= 4 # paga , disponível
			status = @@status_versao_impressas.select{|k,v| k != :pagamento} #todas as opções de status_versao impressa
		elsif status_pgto_to_i == 5 # em disputa
			status = @@status_versao_impressas.select{|k,v| k != :aprovada}
		elsif status_pgto_to_i > 5  # devolvida cancelada ou revogada
			status = @@status_versao_impressas.select{|k,v| k == :cancelada || k == :revogada || k == :devolvida} 
		end
		status
	end

	def gera_dados_se_carteirinha_aprovada
		if self.aprovada? # Status é 'Aprovada'
            # Gera informações  
            estudante = self.estudante
            self.layout_carteirinha = estudante.entidade.layout_carteirinhas.first        if self.layout_carteirinha.blank?
            self.nao_antes = Time.new                                                     if self.nao_antes.blank?
            self.nao_depois = Time.new(Time.new.year+1, 3, 31).to_date                    if self.nao_depois.blank? 
            self.numero_serie = Carteirinha.gera_numero_serie                             if self.numero_serie.blank?
            self.codigo_uso = Carteirinha.gera_codigo_uso                                 if self.codigo_uso.blank?
   			self.qr_code = estudante.entidade.url_qr_code.concat(estudante.chave_acesso)  if self.qr_code.blank?
            
            # Salva documentação do estudante para a carteirinha
            self.foto = estudante.foto                                             if self.foto.blank?
            self.xerox_rg = estudante.xerox_rg                                     if self.xerox_rg.blank?
            self.xerox_cpf = estudante.xerox_cpf                                   if self.xerox_cpf.blank?
            self.comprovante_matricula = estudante.comprovante_matricula           if self.comprovante_matricula.blank?
     	end
	end

	def to_blob
		lyt = self.layout_carteirinha
		img = Magick::Image.read(lyt.anverso.url)
		img = img.first
		
		# Desenha os dados (texto) no layout
		draw = Magick::Draw.new
		draw.pointsize = lyt.tamanho_fonte
		draw.annotate(img, 0, 0, lyt.nome_posx, lyt.nome_posy, self.nome.upcase)                                            	 unless lyt.nome_posx.blank? || lyt.nome_posy.blank? 
		draw.annotate(img, 0, 0, lyt.instituicao_ensino_posx, lyt.instituicao_ensino_posy, self.instituicao_ensino.upcase)       unless lyt.instituicao_ensino_posx.blank? || lyt.instituicao_ensino_posy.blank? 
		draw.annotate(img, 0, 0, lyt.escolaridade_posx, lyt.escolaridade_posy, self.escolaridade.upcase)               	         unless lyt.escolaridade_posx.blank? || lyt.escolaridade_posy.blank? 
		draw.annotate(img, 0, 0, lyt.curso_posx, lyt.curso_posy, self.curso_serie.upcase)                                        unless lyt.curso_posx.blank? || lyt.curso_posy.blank? 
		draw.annotate(img, 0, 0, lyt.data_nascimento_posx, lyt.data_nascimento_posy, self.data_nascimento.strftime("%d/%m/%Y"))  unless lyt.data_nascimento_posx.blank? || lyt.data_nascimento_posy.blank? 
		draw.annotate(img, 0, 0, lyt.rg_posx, lyt.rg_posy, self.rg)                                                  		 	 unless lyt.rg_posx.blank? || lyt.rg_posy.blank? 
		draw.annotate(img, 0, 0, lyt.cpf_posx, lyt.cpf_posy, self.cpf)                                                           unless lyt.cpf_posx.blank? || lyt.cpf_posy.blank?
		draw.annotate(img, 0, 0, lyt.matricula_posx, lyt.matricula_posy, self.matricula)                                         unless lyt.matricula_posx.blank? || lyt.matricula_posy.blank?                    
		draw.annotate(img, 0, 0, lyt.nao_depois_posx, lyt.nao_depois_posy, self.nao_depois.strftime("%d/%m/%Y"))                 unless lyt.nao_depois_posx.blank? || lyt.nao_depois_posy.blank?
		draw.font_weight(700)  # bold                                             			                                             
		draw.annotate(img, 0, 0, lyt.codigo_uso_posx, lyt.codigo_uso_posy, self.codigo_uso.upcase)                         		 unless lyt.codigo_uso_posx.blank? || lyt.codigo_uso_posy.blank? 
		 
		# Desenha foto 
		foto = Magick::Image.read(self.foto.url)
		draw.composite(lyt.foto_posx, lyt.foto_posy, lyt.foto_width, lyt.foto_height, foto[0])    unless data_foto_blank(lyt)
		
		# Cria e Desenha Qr Code
		dir_qr_code = "tmp/#{self.numero_serie}.png"
		qr = RQRCode::QRCode.new( self.qr_code, :size => 6, :level => :h ).to_img 
		qr.resize(lyt.qr_code_width, lyt.qr_code_height).save(dir_qr_code)
		
		qr_code = Magick::Image.read(dir_qr_code)
		draw.composite(lyt.qr_code_posx, lyt.qr_code_posy, lyt.qr_code_width, lyt.qr_code_height, qr_code[0])    unless data_qr_code_blank(lyt)
		draw.draw(img)
		File.delete(dir_qr_code)

		img.to_blob
	end

	def self.zipfile_by_scope carteirinhas
		begin
			# Cria nome do arquivo zip
	        zipfile_name = "carteirinhas.zip"
	        path_zip = "tmp/#{zipfile_name}"

	        # Inicia o arquivo temporario como zip
	       data = Zip::OutputStream.write_buffer do |stream| 
	        	carteirinhas.each do |carteirinha|
		         	begin
		         	file_name = "#{carteirinha.numero_serie}.jpg"
		         	temp = Tempfile.new file_name
		         	img = Magick::Image.from_blob carteirinha.to_blob
		         	img.first.write temp.path #converte para jpg
		         	img = Magick::Image.read temp.path
		         	stream.put_next_entry file_name
		         	stream.write img.first.to_blob
		         	ensure
		         		temp.close
		         		temp.unlink
		         	end
		        end
	        end	 
	       {:stream=>data.string, :filename => zipfile_name}
		ensure
			#File.delete zip
			#File.delete "tmp/arquivo.zip"
		end
	end

	def self.gera_numero_serie
		last = where.not(numero_serie: nil).order(:numero_serie).last 
		last ? last.numero_serie.to_i+1 : 1 
	end

	def self.gera_codigo_uso
		SecureRandom.hex(4).upcase
	end 

	protected
		def vencida
			self.vencimento == "1"	
		end

		def data_foto_blank layout
			layout.foto_posx.blank? || layout.foto_posy.blank? || layout.foto_width.blank? || layout.foto_height.blank?
		end

		def data_qr_code_blank layout
			layout.qr_code_posx.blank? || layout.qr_code_posy.blank? || layout.qr_code_width.blank? || layout.qr_code_height.blank?
		end
end