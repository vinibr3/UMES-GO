ActiveAdmin.register AdminUser do
  menu if: proc{current_admin_user.sim?}, priority: 5, label: "Usuários"
  actions :all, except: [:destroy]

  scope "Todos", :all, default: true
  scope("Ativos"){|scope| scope.where(status: "1")}
  scope("Inativos"){|scope| scope.where(status: "0")}

  permit_params :nome, :email, :cpf, :rg, :expedidor_rg, :uf_expedidor_rg,
                :data_nascimento, :sexo, :celular, :telefone, :logradouro,
                :numero, :complemento, :setor, :cep, :cidade, :uf, :usuario,
                :super_admin, :status, :password, :password_confirmation,
                :cidade_id

  filter :nome
  filter :usuario
  filter :email

  index do
    selectable_column
    #id_column
    column :nome
    column "Usuário", :usuario
    column :email
    column "Status" do |admin_user|
      status_tag(admin_user.status, admin_user.ativo? ? :ok : :warning)
    end
    column :telefone
    column "Cidade", :cidade_nome
    actions
  end

  show do 
        panel "Dados de Usuário" do 
            attributes_table_for admin_user do
                row :id
                row :nome
                row :usuario
                row :email
                row :password
                row :super_admin
                row :status
            end
        end
        panel "Dados Pessoais" do 
          attributes_table_for admin_user do
            row :cpf
            row :rg
            row :expedidor_rg
            row :uf_expedidor_rg
            row "Data Nascimento" do |estudante|
              estudante.data_nascimento 
            end
            row "Gênero" do
              admin_user.sexo
            end
            row :celular
            row :telefone
          end
        end
        panel "Endereço" do 
          attributes_table_for admin_user do
            row :logradouro
            row "Número" do
              admin_user.numero
            end
            row :complemento
            row "BAIRRO" do
              admin_user.setor
            end  
            row :cep
            row "Cidade" do
              admin_user.cidade_nome
            end
            row "UF" do
              cidade = admin_user.cidade if admin_user.cidade
              estado = cidade.estado if cidade
              estado.sigla if estado
            end
          end
        end
        if current_admin_user.sim?
          panel "Meta Dados" do 
            attributes_table_for admin_user do 
              row :reset_password_token
              row :reset_password_sent_at
              row :remember_created_at
              row :sign_in_count
              row :current_sign_in_at
              row :last_sign_in_at
              row :current_sign_in_ip
              row :last_sign_in_ip
              row :created_at
              row :update_at
            end
          end
        end
    end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Dados de Usuário" do 
      f.input :nome
      f.input :usuario
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :super_admin, as: :radio
      f.input :status, as: :radio
    end
    f.inputs "Dados Pessoais" do
      f.input :cpf, label:"CPF"
      f.input :rg, label:"RG"
      f.input :expedidor_rg, label:"Expedidor RG"
      f.input :uf_expedidor_rg, label:"UF Expedidor RG", as: :select, collection: Estado.all.map{|e| e.sigla}
      f.input :data_nascimento, label: "Data de Nascimento", as: :datepicker, datepicker_options: { day_names_min: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
                                                                                                    month_names_short: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],
                                                                                                    year_range: "1930:", show_anim: "slideDown", changeMonth: true, changeYear: true}
      f.input :sexo, as: :radio, collection: ["Masculino", "Feminino"], label: "Gênero"
      f.input :celular
      f.input :telefone
    end
    f.inputs "Endereço" do 
      f.input :logradouro
      f.input :numero, label: "Número"
      f.input :complemento
      f.input :setor , label:"Bairro"
      f.input :cep, label: "CEP"
      f.input :estado_id, label: "UF", prompt: "Selecione a UF", :input_html=>{:id=>"uf-select"},
              collection: Estado.all.map{|e| [e.sigla, e.id]}, include_blank: false
      f.input :cidade_id, :input_html=>{:id=>"cidades-select"}, prompt: "Selecione a Cidade", as: :select,
              collection: Cidade.where(estado_id: f.object.estado_id).map{|c| [c.nome, c.id]}
    end
    f.actions
    # Script para escolher 'cidade' a partir de 'uf'
    render inline: "<script type='text/javascript'> $('#uf-select').change(function(){ 
      var uf_id = $('#uf-select').val();
      var url = '/estados/'.concat(uf_id).concat('/cidades.js').concat('?elemento_id=cidades-select');
      $.ajax({
          url: url,
          dataType: 'script'
        });
      });</script>"
  end

end