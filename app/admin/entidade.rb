ActiveAdmin.register Entidade do 
	menu if: proc{current_admin_user.super_admin?}, label: "Entidade", priority: 6

	permit_params :nome, :sigla, :email, :cnpj, :chave_privada, :password,
	              :common_name_certificado, :organizational_unit, :valor_carteirinha,
	              :frete_carteirinha, :telefone, :logradouro, :numero, :complemento,
	              :setor, :cep, :cidade, :uf, :nome_presidente, :email_presidente,
	              :cpf_presidente, :rg_presidente, :expedidor_rg_presidente,
	              :uf_expedidor_rg_presidente, :data_nascimento_presidente,
	              :sexo_presidente, :celular_presidente, :telefone_presidente,
	              :logradouro_presidente, :numero_presidente, :complemento_presidente,
	              :cep_presidente, :cidade_presidente, :uf_presidente, 
	              :authority_key_identifier, :crl_dist_points, :url_qr_code, :authority_info_access

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
		actions
	end

	show do
		panel "Dados da Entidade" do 
			attributes_table_for entidade do 
				row :nome
				row :sigla
				row :email
				row :cnpj
				row :chave_privada_file_name
				row :password
				row :common_name_certificado
				row :organizational_unit
				row :valor_carteirinha
				row :frete_carteirinha
				row :telefone
				row :authority_key_identifier, "Chave Pública"
				row :crl_dist_points, "URL CRL Dist. Points"
				row :url_qr_code, "URl QR-Code"
				row :authority_info_access, "URL Authority Info Access"
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
			f.input :chave_privada
			f.input :password
			f.input :common_name_certificado
			f.input :organizational_unit
			f.input :valor_carteirinha
			f.input :frete_carteirinha
			f.input :telefone
			f.input :authority_key_identifier, label: "Chave Pública"
			f.input :crl_dist_points, label: "URL CRL Dist. Points"
			f.input :authority_info_access, "URL Authority Info Access"
			f.input :url_qr_code, label: "URL Qr-Code"
		end
		f.inputs "Endereço da Entidade" do 
			f.input :logradouro
			f.input :numero
			f.input :complemento
			f.input :setor
			f.input :cep
			f.input :cidade
			f.input :uf
		end
		f.inputs "Dados do Presidente" do 
			f.input :nome_presidente, label: "Presidente"
			f.input :email_presidente, lael: "email"
			f.input :cpf_presidente, label: "CPF"
			f.input :rg_presidente, label: "RG"
			f.input :expedidor_rg_presidente, label: "Expedidor RG"
			f.input :uf_expedidor_rg_presidente, label: "UF Expedidor"
			f.input :data_nascimento_presidente, label: "Data Nascimento",as: :datepicker
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

	controller do
		def create 
			if Entidade.count == 0
				create!
			else
				redirect_to admin_entidades_path
				flash[:notice] = "Somente uma entidade pode ser cadastrada."
			end
		end
	end

end