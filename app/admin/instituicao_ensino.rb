ActiveAdmin.register InstituicaoEnsino do 
	menu priority: 1, parent: "Configurações", label:'Instituições de Ensino'
	actions :all, except: [:destroy]

	permit_params :nome, :sigla, :cnpj, :logradouro, :numero,
								:cep, :complemento, :cidade_id, :estado_id,
								:entidade_id 
	
	filter :nome
	filter :sigla
	filter :cnpj

	index do
		selectable_column
		column :nome
		column :sigla
		column :cnpj
		actions
	end

	show do
		panel "Dados da Instituição de Ensino" do
			attributes_table_for instituicao_ensino do
				row :nome
				row :sigla
				row "CNPJ" do
					instituicao_ensino.cnpj
				end
			end
		end
		panel "Endereço" do
			attributes_table_for instituicao_ensino do
				row :logradouro
				row :numero
				row :cep
				row :complemento
				row "Cidade" do
					instituicao_ensino.cidade_nome
				end
				row "UF" do
					instituicao_ensino.estado_sigla
				end
			end
		end
	end

	form do |f|
		f.semantic_errors *f.object.errors.keys
		f.inputs "Dados da Instituição de Ensino" do 
			f.input :nome
			f.input :sigla
			f.input :cnpj, label: "CNPJ"
		end
		f.inputs "Endereço" do
			f.input :logradouro
			f.input :numero, label: "Número"
			f.input :cep, label: "CEP"
			f.input :complemento
			f.input :estado_id, collection: Estado.order(:sigla).map{|e| [e.sigla, e.id]} ,label: "UF", as: :select, :input_html=>{:id=>"uf-select"}, include_blank: false, prompt: "Selecione a UF"
			f.input :cidade_id, collection: Cidade.order(:nome).where(estado_id: f.object.estado_id).map{|c| [c.nome, c.id]}, as: :select, prompt: "Selecione a Cidade", :input_html=>{:id=>"cidades-select"}
		end
		f.actions
		# Script para escolher 'cidade' a partir de 'uf'
    render inline: "<script type='text/javascript'> 
    $('#uf-select').change(function(){ 
      var uf_id = $('#uf-select').val();
      var url = '/estados/'.concat(uf_id).concat('/cidades.js').concat('?elemento_id=cidades-select');
      $.ajax({
          url: url,
          dataType: 'script'
        });
      });</script>"
	end

	collection_action :autocomplete, method: :get do 
		if authenticate_admin_user!
			param = I18n.transliterate(params[:term].mb_chars.upcase)
			instituicoes = InstituicaoEnsino.order(:nome).where("unaccent(upper(nome)) ILIKE ?", "%#{param}%").limit(50)
			render json: instituicoes.map{|i| {id: i.id, value: i.nome, label: i.nome_autocomplete, uf_id: i.estado_id, cidade_id: i.cidade_id}}, root: false
		end
	end

end