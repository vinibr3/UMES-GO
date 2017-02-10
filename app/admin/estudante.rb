ActiveAdmin.register Estudante do
  menu priority: 2
  actions :all, except: [:destroy]

  jcropable

  permit_params :nome, :cpf, :rg, :data_nascimento, :sexo, :telefone,
                :logradouro, :complemento, :setor, :cep, :cidade, :uf,
                :instituicao_ensino, :curso_serie, :matricula, :foto, 
                :comprovante_matricula, :xerox_rg, :email, :password, 
                :celular, :numero, :expedidor_rg, :uf_expedidor_rg,
                :cidade_inst_ensino, :uf_inst_ensino, :xerox_cpf, 
                :instituicao_ensino_id, :curso_id, :cidade_id, 
                :entidade_id, :admin_user_id

  filter :email
  filter :nome
  if Entidade.count > 1
    filter :entidade, as: :select, collection: Entidade.all.map{|e| [e.nome, e.id]}
  end 
  filter :rg
  filter :cpf
  filter :matricula
  filter :instituicao_ensino, as: :select, collection: InstituicaoEnsino.all.map{|i| [i.nome, i.id]}
  filter :curso, as: :select,  collection: Curso.all.map{|i| [i.nome, i.id]}
  filter :admin_user, label:"Cadastrado Por", collection: AdminUser.all.map{|u| [u.nome, u.id]}, :if=>proc{current_admin_user.sim?}
  
  index do
    selectable_column
    column :email
    column :nome
    if Entidade.count > 1
      column "Entidade" do |estudante|
        estudante.entidade.sigla if estudante.entidade
      end
    end
    column "RG" do |estudante|
      estudante.rg
    end
    column "CPF" do |estudante|
      estudante.cpf
    end
    column "Cidade" do |estudante|
      estudante.cidade.nome if estudante.cidade
    end 
    actions
  end

  show do
    panel "Dados Pessoais" do
      attributes_table_for estudante do
        row :nome
        row :email
        row :data_nascimento
        row :cpf
        row :rg
        row :expedidor_rg, "Expedidor RG"
        row :uf_expedidor_rg, "UF Expedidor RG"
        row :foto do
          a estudante.foto_file_name, class: "show-popup-link", href: estudante.foto.url
        end
        row "Xerox RG" do
          a estudante.xerox_rg_file_name, href: estudante.xerox_rg.url 
        end
        row "Xerox CPF" do
          a estudante.xerox_cpf_file_name, href: estudante.xerox_cpf.url
        end
        row "Gênero" do
          estudante.sexo
        end
        row :telefone
        row :celular
        row :chave_acesso
      end 
    end 
    panel "Dados Estudantis" do
      attributes_table_for estudante do 
        row "Entidade" do
          estudante.entidade_nome
        end
        row "Instituição Ensino" do 
          estudante.instituicao_ensino_nome
        end
        row "Escolaridade" do 
          estudante.escolaridade_nome
        end
        row "Curso" do 
          estudante.curso_nome
        end 
        row :matricula
        row "Comprovante de Matrícula" do
          a estudante.comprovante_matricula_file_name, href: estudante.comprovante_matricula.url
        end
      end
    end
    panel "Endereço" do
      attributes_table_for estudante do
        row :logradouro
        row "NÚMERO" do
          estudante.numero
        end
        row :complemento
        row "Cidade" do
          estudante.cidade.nome if estudante.cidade
        end
        row "UF" do 
          estudante.estado_nome
        end
        row :cep 
      end
    end
    if current_admin_user.sim?
      panel "Meta Dados" do 
        attributes_table_for estudante do
          row "Cadastrado Por" do
            estudante.admin_user.usuario if estudante.admin_user
          end  
          row :foto_file_name
          row :foto_content_type
          row :foto_file_size
          row :foto_update_at
          row :comprovante_matricula_file_name
          row :comprovante_matricula_content_type
          row :comprovante_matricula_file_size
          row :comprovante_matricula_update_at
          row :xerox_rg_file_name
          row :xerox_rg_content_type
          row :xerox_rg_file_size
          row :xerox_rg_update_at
          row :provider
          row :uid 
          row :oauth_token
          row :oauth_expires_at
          row :created_at
          row :updated_at
          row :encrypted_password
          row :reset_password_token
          row :reset_password_sent_at
          row :remember_created_at
          row :sign_in_count
          row :current_sign_in_at
          row :last_sign_in_at
          row :current_sign_in_ip
          row :last_sign_in_ip
        end 
      end
    end
    render inline: "<script type='text/javascript'>$('.show-popup-link').magnificPopup({type: 'image'});</script>"
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Dados Pessoais" do
      f.input :email
      f.input :nome
      f.input :cpf, label: "CPF"
      f.input :rg, label: "RG"
      f.input :expedidor_rg, label: "Expedidor RG"
      f.input :uf_expedidor_rg, collection: Estado.all.map{|e| e.sigla} ,label: "UF Expedidor RG"
      f.input :data_nascimento, label: "Data de Nascimento", as: :datepicker, datepicker_options: { day_names_min: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
                                                                                                    month_names_short: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],
                                                                                                    year_range: "1930:", show_anim: "slideDown", changeMonth: true, changeYear: true}
      f.input :sexo, collection: Estudante.class_variable_get(:@@GENEROS), label: "Gênero", :as => :radio
      f.input :telefone
      f.input :celular
      f.input :foto, :hint => "Imagem Atual: #{f.object.foto_file_name}", as: :jcropable, jcrop_options: {aspectRatio: 0.75, showDimensions: false, maxSize: [400,500]}
      f.input :xerox_rg, :hint => "Imagem Atual: #{f.object.xerox_rg_file_name}", label: "Xerox RG"
      f.input :xerox_cpf, :hint => "Imagem Atual: #{f.object.xerox_cpf_file_name}", label: "Xerox CPF"
    end
    f.inputs "Dados Estudantis" do
      f.input :entidade, collection: Entidade.all.map{|e| [e.nome, e.id]}, prompt:"Selecione a Entidade", 
              label: "Entidade", include_blank: false
      f.input :instituicao_ensino, collection: InstituicaoEnsino.all.map{|i| [i.nome, i.id] }, 
              prompt: "Selecione a Instituição de Ensino", label: "Instituição de Ensino"  
      f.input :escolaridade_id, :as => :select, prompt: "Selecione a Escolaridade", :input_html=>{:id=>"escolaridades-select"},
              collection: Escolaridade.escolaridades.map{|e| [e.nome, e.id]}, label: "Escolaridade"    
      f.input :curso, :as => :select, prompt: "Selecione o Curso", :input_html=>{id: "cursos-select"}, 
              collection: Curso.where(escolaridade_id: f.object.escolaridade_id).map{|c| [c.nome, c.id]}       
      f.input :matricula, label: "Matrícula"
      f.input :comprovante_matricula, :hint => "Imagem Atual: #{f.object.comprovante_matricula_file_name}", label: "Comprovante de Matrícula"
    end
    f.inputs "Endereço" do
      f.input :logradouro
      f.input :numero, label: "Número"
      f.input :complemento
      f.input :cep, label: "CEP"
      f.input :uf, prompt: "Selecione a UF", label: "UF", :input_html=>{:id=>"uf-select"}, include_blank: false,
              collection: Estado.all.map{|e| [e.sigla, e.id]}
      f.input :cidade, :as => :select, prompt: "Selecione a Cidade", :input_html=>{:id=>"cidades-select"},
              collection: Cidade.where(estado_id: f.object.estado_id).map{|c| [c.nome, c.id]}, include_blank: false
    end
    if current_admin_user.sim? && !f.object.new_record?
      f.inputs "Cadastro" do
        f.input :admin_user, label: "Cadastrado Por", collection: AdminUser.all.map{|u| [u.nome, u.id]}
      end
    end
    f.actions
    # Script para escolher 'curso' a partir de 'escolaridade'
    render inline: "<script type='text/javascript'> $('#escolaridades-select').change(function(){ 
      var escolaridade_id = $('#escolaridades-select').val();
      var url = '/escolaridades/'.concat(escolaridade_id).concat('/cursos.js');
      $.ajax({
          url: url,
          dataType: 'script'
        });
      });</script>"
    # Script para escolher 'cidade' a partir de 'uf'
    render inline: "<script type='text/javascript'> $('#uf-select').change(function(){ 
      var uf_id = $('#uf-select').val();
      var url = '/estados/'.concat(uf_id).concat('/cidades.js');
      $.ajax({
          url: url,
          dataType: 'script'
        });
      });</script>"
  end

  before_create do |estudante|
    estudante.admin_user = current_admin_user
    estudante.password = Devise.friendly_token
    estudante.skip_confirmation!
    estudante.skip_confirmation_notification!
  end

  after_create do |estudante|
    #EstudanteNotificacoes.create_notificacoes(estudante).deliver_later
  end

  # Actions
  
  # Action item que cria a carteirinha para o aluno
  action_item :new_carteirinha, only: :show do
    # Faz a requisição no controller 'admin/carteirinha' via 'post' para criar a carteirinha 
    link_to "Criar Carteirinha", "/admin/carteirinhas?estudante_id=#{resource.id}", method: :post
  end 

end