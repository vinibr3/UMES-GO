ActiveAdmin.register Entidade do 
	menu if: proc{current_admin_user.super_admin?}, priority: 4
	actions :all, except: [:destroy]

	permit_params :nome, :sigla, :email, :cnpj, :chave_privada, :password,
	              :instituicao_ensino, :organizational_unit, :valor_carteirinha,
	              :frete_carteirinha, :telefone, :logradouro, :numero, :complemento,
	              :setor, :cep, :cidade, :uf, :nome_presidente, :email_presidente,
	              :cpf_presidente, :rg_presidente, :expedidor_rg_presidente,
	              :uf_expedidor_rg_presidente, :data_nascimento_presidente,
	              :sexo_presidente, :celular_presidente, :telefone_presidente,
	              :logradouro_presidente, :numero_presidente, :complemento_presidente,
	              :cep_presidente, :cidade_presidente, :uf_presidente, 
	              :usuario, :url_qr_code, :token_certificado, :dominio, :valor_certificado

	filter :nome
	filter :sigla

	index do 
		selectable_column
		column :nome
		column :sigla
		column :email
		column :valor_carteirinha
		column :frete_carteirinha
		column :telefone
		column :presidente
		column :valor_certificado
		actions
	end

	show do
		panel "Dados da Entidade" do 
			attributes_table_for entidade do 
				row :nome
				row :sigla
				row :email
				row :cnpj
				row :logo_file_name
				row :valor_carteirinha
				row :frete_carteirinha
				row :valor_certificado
				row :telefone
				row :usuario, "Chave Pública"
				row :token_certificado, "Senha"
				row :dominio, "Domínio"
				row :url_qr_code, "URl QR-Code"
				row :cadeia_certificados_raiz_url, "Cadeia de Certificados Raiz (URL)"
				row :lista_certificados_revogados_url, "CRL Ponto de Distribuição (URL)"
			end
		end
		panel "Endereço da Entidade" do 
			attributes_table_for entidade do
				row :logradouro
				row :numero
				row :complemento
				row :setor
				row :cep
				row :cidade
				row :uf
			end
		end 
		panel "Dados do Presidente" do 
			attributes_table_for entidade do
				row :nome_presidente, "Presidente"
				row :email_presidente, "email"
				row :cpf_presidente, "CPF"
				row :rg_presidente, "RG"
				row :expedidor_rg_presidente, "Expedidor RG"
				row :uf_expedidor_rg_presidente, "UF Expedidor"
				row :data_nascimento_presidente, "Data Nascimento"
				row :sexo_presidente, "Sexo"
				row :celular_presidente, "Celular"
				row :telefone_presidente, "Telefone"
				row :logradouro_presidente, "Logradouro"
				row :numero_presidente, "Numero"
				row :complemento_presidente, "Complemento"
				row :cep_presidente, "CEP"
				row :cidade_presidente, "Cidade"
				row :uf_presidente, "UF"
			end
		end
		render inline: "<script type='text/javascript'>$('.show-popup-link').magnificPopup({type: 'image'});</script>" 
	end

	form do |f|
		f.semantic_errors *f.object.errors.keys
		f.inputs "Dados da Entidade" do 
			f.input :nome
			f.input :sigla
			f.input :email
			f.input :cnpj
			f.input :logo
			f.input :valor_carteirinha
			f.input :frete_carteirinha
			if current_admin_user.sim? && current_admin_user.email == "doti@doti.com.br"
				f.input :valor_certificado
			end
			f.input :telefone
			f.input :usuario
			f.input :token_certificado, label: "Senha"
			f.input :dominio, label: "Domínio"
			f.input :url_qr_code, label: "URL Qr-Code", :hint=>"Domínio da entidade + '/certificados/'"
		end
		f.inputs "Endereço da Entidade" do 
			f.input :logradouro
			f.input :numero
			f.input :complemento
			f.input :setor
			f.input :cep
			f.input :uf, as: :select, collection: Estado.siglas
			f.input :cidade
		end
		f.inputs "Dados do Presidente" do 
			f.input :nome_presidente, label: "Presidente"
			f.input :email_presidente, lael: "email"
			f.input :cpf_presidente, label: "CPF"
			f.input :rg_presidente, label: "RG"
			f.input :expedidor_rg_presidente, label: "Expedidor RG"
			f.input :uf_expedidor_rg_presidente, label: "UF Expedidor"
			f.input :data_nascimento_presidente, label: "Data Nascimento", as: :datepicker, datepicker_options: { day_names_min: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
                                                                                                    month_names_short: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],
                                                                                                    year_range: "1930:", show_anim: "slideDown", changeMonth: true, changeYear: true}
			f.input :sexo_presidente, label: "Sexo"
			f.input :celular_presidente, label: "Celular"
			f.input :telefone_presidente, label: "Telefone"
			f.input :logradouro_presidente, label: "Logradouro"
			f.input :numero_presidente, label: "Numero"
			f.input :complemento_presidente, label: "Complemento"
			f.input :cep_presidente, label: "CEP"
			f.input :cidade_presidente, label: "Cidade"
			f.input :uf_presidente, label: "UF"
		end
		f.actions
	end

	
	sidebar "Certificado de Atributo", only: [:show, :new] do
		ul do
		    li link_to "Extensões", admin_entidade_extensoes_path(resource)
		end
	end
	
end