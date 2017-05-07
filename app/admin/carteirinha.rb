require 'zip'
ActiveAdmin.register Carteirinha do
   menu priority: 3
   actions :all, except: [:destroy,:new]
   config.sort_order = 'aprovada_em_desc'

   scope "Novas", default: true do |carteirinha|
    carteirinha.where(admin_user: nil)
   end

   Carteirinha.status_versao_impressas.each do |status|
    scope status.second do |carteirinha|
        if current_admin_user.sim?
          carteirinha.where(status_versao_impressa: status.second)
        else
          carteirinha.where(status_versao_impressa: status.second, admin_user_id: current_admin_user.id)
        end
    end
   end 

    permit_params :nome, :instituicao_ensino, :curso_serie, :matricula, :rg,
				  :data_nascimento, :cpf, :numero_serie, :validade, :qr_code,
				  :layout_carteirinha_id, :vencimento, :estudante_id, :foto, 
          :status_versao_impressa, :expedidor_rg, :uf_expedidor_rg,
          :cidade_inst_ensino,:escolaridade, :uf_inst_ensino, 
          :foto_file_name, :nao_antes, :nao_depois, :codigo_uso,
          :alterado_por, :valor, :forma_pagamento, :status_pagamento, 
          :transaction_id, :certificado, :xerox_rg, :xerox_cpf, 
          :comprovante_matricula, :carteirinha, :id, :aprovada_em, :admin_user_id
	
  filter :nome
	filter :numero_serie
  filter :transaction_id
  filter :aprovada_em, label: "Data Aprovação", as: :date_range
  filter :admin_user, label:"Criada Por", collection: proc{AdminUser.all.map{|u| [u.nome, u.id]}}, :if=>proc{current_admin_user.sim?}
	
	index do
		selectable_column
    	column :nome 
    	column "Curso" do |carteirinha|
        carteirinha.curso_serie
      end
      column "Instituição de Ensino" do |carteirinha|
        carteirinha.instituicao_ensino
      end
      column "Pagamento" do |carteirinha|
        status_tag(carteirinha.status_pagamento, carteirinha.status_tag_status_pagamento)
      end
      column "Status" do |carteirinha|
        status = carteirinha.status_versao_impressa
        status_tag( status ? status : '', carteirinha.status_tag_versao_impressa)
      end
      if current_admin_user.sim?
        column "Criada Por" do |carteirinha|
          carteirinha.admin_user.usuario if carteirinha.admin_user
        end
      end
      actions
	end

    show do
        panel "Dados do Estudante" do 
            attributes_table_for carteirinha do 
                row :nome 
                row :rg
                row :cpf
                row :data_nascimento
                row :foto do 
                    a carteirinha.foto_file_name, class: "show-popup-link", href: carteirinha.foto.url
                end
                row :xerox_rg do 
                    a carteirinha.xerox_rg_file_name, href: carteirinha.xerox_rg.url
                end
                 row :xerox_cpf do
                    a carteirinha.xerox_cpf_file_name, href: carteirinha.xerox_cpf.url
                end
            end
        end
        panel "Dados Escolares" do 
            attributes_table_for carteirinha do
                row :instituicao_ensino
                row :cidade_inst_ensino
                row :uf_inst_ensino
                row :escolaridade
                row :curso_serie
                row :matricula
                row :comprovante_matricula do
                    a carteirinha.comprovante_matricula_file_name, href: carteirinha.comprovante_matricula.url
                end
            end
        end
        panel "Dados da Carteirinha" do
            attributes_table_for carteirinha do 
                row :nao_antes
                row :nao_depois 
                row :codigo_uso
                row :qr_code
                row :certificado
                row :numero_serie
                row :layout_carteirinha_id
                row :estudante_id
            end
        end
        panel "Dados da Solicitaçao" do 
            attributes_table_for carteirinha do
                row "Status da Versão Impressa" do 
                    carteirinha.status_versao_impressa.humanize
                end
                row :valor
                row "Forma Pagamento" do
                  carteirinha.forma_pagamento.humanize
                end
                row "Status Pagamento" do
                  carteirinha.status_pagamento.humanize
                end 
                row "Transação" do
                  carteirinha.transaction_id
                end
                row "Criada por" do
                  carteirinha.admin_user.usuario if carteirinha.admin_user
                end 
                row "Data Aprovação" do
                  carteirinha.aprovada_em
                end
                row "Última Alteração" do 
                  carteirinha.alterado_por
                end
            end
        end
        render inline: "<script type='text/javascript'>$('.show-popup-link').magnificPopup({type: 'image'});</script>"
    end

    form do |f|
        f.semantic_errors *f.object.errors.keys
            f.inputs "Dados do Estudante" do
                f.input :nome 
                f.input :rg
                f.input :cpf
                f.input :data_nascimento, as: :datepicker, datepicker_options: { day_names_min: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
                                                                                                    month_names_short: ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],
                                                                                                    year_range: "1930:", show_anim: "slideDown", changeMonth: true, changeYear: true}
                f.input :foto, :hint => "Imagem Atual: #{f.object.foto_file_name}"
                f.input :xerox_rg, :hint => "Imagem Atual: #{f.object.xerox_rg_file_name}"
                f.input :xerox_cpf, :hint => "Imagem Atual: #{f.object.xerox_cpf_file_name}"
            end
            f.inputs "Dados Escolares" do
                f.input :instituicao_ensino, :input_html=>{:id=>"instituicao-ensino-autocomplete-admin"}, label: "Instituição de ensino"
                f.input :escolaridade, collection: Escolaridade.order(:nome).map(&:nome), include_blank: false, :input_html=>{:id=>"escolaridades-select"}, label: "Escolaridade"
                f.input :curso_serie, collection: Curso.order(:nome).where(escolaridade_id: Escolaridade.find_by_nome(f.object.escolaridade).id).map(&:nome), 
                        include_blank: false, label: "Curso", :input_html=>{id: "cursos-select"}
                f.input :matricula
                f.input :comprovante_matricula, :hint => "Imagem Atual: #{f.object.comprovante_matricula_file_name}"
            end
            if current_admin_user.sim?
              f.inputs "Dados do Documento" do
                  f.input :nao_antes, as: :datepicker
                  f.input :nao_depois, as: :datepicker
                  f.input :codigo_uso
                  f.input :qr_code
                  f.input :certificado
                  f.input :numero_serie
                  f.input :layout_carteirinha_id, label:"Layout"
                  f.input :estudante_id, label: "Estudante ID"
              end
            end 
            f.inputs "Dados da Solicitação" do
                f.input :status_pagamento, as: :select, include_blank: false, prompt: "Selecione status do pagamento", 
                        label: "Status do Pagamento", :input_html=>{:id=>"status-pagamento-select"}
                f.input :status_versao_impressa, label: "Status da Versão Impressa", include_blank: false, :input_html=>{:id=>"status-versao-impressas-select"},
                        collection: Carteirinha.show_status_carteirinha_apartir_do_status_pagamento(f.object.status_pagamento).map{|k,v| [v,k]} 
                f.input :forma_pagamento, as: :select, include_blank: false, prompt: "Selecione forma de pagamento", label: "Forma de Pagamento"
                if !f.object.new_record? && current_admin_user.sim?
                  f.input :admin_user, label: "Criado Por", collection: AdminUser.all.map{|u| [u.nome, u.id]}
                end
                f.input :transaction_id, label: "Transação"
            end
            f.actions
      # Script para escolher 'curso' a partir de 'escolaridade'
    render inline: "<script type='text/javascript'> $('#escolaridades-select').change(function(){ 
      var escolaridade_id = $('#escolaridades-select').val();
      var url = '/escolaridades/'.concat(escolaridade_id).concat('/cursos.js').concat(?elemento_id=cidades-select);
      $.ajax({
          url: url,
          dataType: 'script'
        });
      });</script>"
      render inline: "<script type='text/javascript'>
        $('#status-pagamento-select').change(function(){
          var status_pagamento = $('#status-pagamento-select').val();
          $.ajax({
            url: '/carteirinhas/status?status_pagamento='.concat(status_pagamento),
            dataType: 'script'
          });
        });
        </script>"
      render inline: "<script type='text/javascript'>
        $('#instituicao-ensino-autocomplete-admin').autocomplete({source: '/admin/instituicao_ensinos/autocomplete'});</script>"
    end

    before_update do |carteirinha|
      if carteirinha.status_versao_impressa.to_sym == :aprovada
        carteirinha.aprovada_em = Time.new          if carteirinha.aprovada_em.blank?
      end
      carteirinha.admin_user = current_admin_user if carteirinha.admin_user.blank?
      carteirinha.alterado_por = current_admin_user.usuario
    end

     #Action items 
    action_item :download, only: :show do
        link_to 'Download ', download_admin_carteirinha_path(carteirinha)
    end

    #Actions
    member_action :download, method: :get do
       carteirinha = Carteirinha.find(params[:id])
       if carteirinha
        if carteirinha.status_versao_impressa_to_i < 2 
            flash[:error]="Status da CIE não permite o download."
            redirect_to :back
        else
            send_data carteirinha.to_blob, type: 'image/jpg', filename: "#{carteirinha.numero_serie}.jpg" 
        end
       else
        flash[:error]="Dados não encontrados."
        redirect_to :back
       end
    end

    batch_action :download do |ids|
      @carteirinhas = Carteirinha.find(ids) 
      @carteirinhas.delete_if{|carteirinha| carteirinha.status_versao_impressa_to_i < 2} # Status anterior a 'Aprovada'
      data = Carteirinha.zipfile_by_scope @carteirinhas
      send_data  data[:stream], type:'application/zip', filename: data[:filename]
    end

    controller do
      def create
        @estudante = Estudante.find(params[:estudante_id])
        @carteirinha = nil
        atributos = @estudante.atributos_nao_preenchidos
        if atributos.count > 0 
          campos = ""
          atributos.collect{|f| campos.concat(f.concat(", "))}
          puts "ATRIBUTOS #{atributos}"
          flash[:alert] = "Não foi possível criar carteirinha. Campo(s) #{campos} não preenchido(s)."
          redirect_to edit_admin_estudante_path @estudante
        else
          if @estudante.entidade.layout_carteirinhas.empty?
            flash[:alert] = "Não foi possível criar carteirinha. Entidade #{@estudante.entidade.nome} não tem nenhum layout de carteirinha."
            redirect_to :back
          else
            @carteirinha = @estudante.carteirinhas.build do |c|
              # Dados pessoais
              c.nome = @estudante.nome
              c.rg   = @estudante.rg
              c.cpf  = @estudante.cpf
              c.data_nascimento = @estudante.data_nascimento
              c.expedidor_rg = @estudante.expedidor_rg
              c.uf_expedidor_rg = @estudante.uf_expedidor_rg
              c.foto = @estudante.foto
              c.xerox_rg = @estudante.xerox_rg
              c.xerox_cpf = @estudante.xerox_cpf
              c.comprovante_matricula = @estudante.comprovante_matricula

              # Dados estudantis
              c.matricula = @estudante.matricula
              c.instituicao_ensino = @estudante.instituicao_ensino.nome
              c.cidade_inst_ensino = @estudante.instituicao_ensino.cidade.nome
              c.uf_inst_ensino = @estudante.instituicao_ensino.estado.sigla
              c.escolaridade = @estudante.escolaridade_nome
              c.curso_serie = @estudante.curso_nome
                    
              # Dados de pagamento
              c.valor = @estudante.entidade.valor_carteirinha.to_f+@estudante.entidade.frete_carteirinha.to_f
              c.status_versao_impressa = :pagamento #status versao impressa
              c.status_pagamento = :iniciado  #status pagamento
              c.forma_pagamento = :a_definir  #forma pagamento
                  
              # Dados do Usuario admin
              c.admin_user = current_admin_user

              # Layout 
              c.layout_carteirinha = @estudante.entidade.layout_carteirinhas.last
            end
            if @carteirinha.save 
              flash[:success] = "Carteirinha criada para o estudante: #{@estudante.nome}. Altere os dados de pagamento."
              render :edit
            else
              flash[:error] = "Não foi possível criar carteirinha. #{@carteirinha.errors.full_messages}"
              redirect_to :back
            end
          end  
      end
    end
      # Permite envio de notificações para o aluno quando alterado o status da carteirinha 
      # def update(options={}, &block) 
      #   if resource.status_versao_impressa != params[:carteirinha][:status_versao_impressa]  
      #     #EstudanteNotificacoes.status_notificacoes(@carteirinha).deliver_now if resource.update_attributes(permitted_params[:carteirinha])
      #   end
      #   super do |success, failure| 
      #     block.call(success, failure) if block
      #     failure.html { render :edit }
      #   end
      # end
    end
end