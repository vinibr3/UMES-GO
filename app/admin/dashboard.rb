ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") } # if: proc{current_admin_user.super_admin?}

  content title: proc{ I18n.t("active_admin.dashboard") } do
    
    # Dados de Estudante
    estudantes_cadastrados_manualmente = Estudante.where.not(admin_user_id: nil).count
    estudantes_cadastrados_pelo_site = Estudante.where(admin_user_id: nil).count
    estudantes_totais_cadastrados = Estudante.count

    # Dados de Carteirinha
    carteirinhas_totais = Carteirinha.count
    carteirinhas_novas = Carteirinha.where(admin_user_id: nil).count
    carteirinhas_count = Hash.new
    Carteirinha.status_versao_impressas.each do |status|
        carteirinhas_count[status.second] = Carteirinha.where(status_versao_impressa: status.second).count
    end

    # Dados de Curso/Escolaridade
    cursos_total = Curso.count
    cursos_por_escolaridade = Hash.new
    Escolaridade.all.each do |escolariade|
        cursos_por_escolaridade[escolariade.nome] = escolariade.cursos.count
    end

    panel "Dados Gerais" do
       dados = {entidades: Entidade.count, estudantes: Estudante.count, carteirinhas: Carteirinha.count, usuarios: AdminUser.count,
                instituicoes_ensino: InstituicaoEnsino.count, cursos: Curso.count, escolaridades: Escolaridade.count, 
                eventos: Evento.count, avisos: Aviso.count, noticias: Noticia.count }
       
       attributes_table_for dados do
            row :entidades
            row :estudantes do
                estudantes_pie_3d_chart [estudantes_cadastrados_manualmente, estudantes_cadastrados_pelo_site], estudantes_totais_cadastrados if estudantes_totais_cadastrados > 0
            end
            row :carteirinhas do
                carteirinhas_pie_3d_chart carteirinhas_count, carteirinhas_totais if carteirinhas_totais > 0
            end
            row "Usuários" do 
                dados[:usuarios]
            end
            row "Instituições de Ensino" do
                dados[:instituicoes_ensino]
            end
            row :eventos
            row :avisos
            row "Notícias" do
                dados[:noticias]
            end
            row :cursos do
                cursos_pie_3d_chart cursos_por_escolaridade, cursos_total if cursos_total > 0
            end
        end
    end

    # panel "Dados Operacionais" do 
    #     primeira_carteira = Carteirinha.select(:aprovada_em).order(:aprovada_em).first
    #     ultima_carteira = Carteirinha.select(:aprovada_em).order(:aprovada_em).last
    #     carteirinhas_by_usuarios = Hash.new
    #     AdminUser.all.each do |u| 
            
    #         carteirinhas_by_usuarios[u.usuario] = u.carteirinhas.where(status_versao_impressa: "Aprovada").count

    #     end
    #     div class:"", style:"text-align: center;" do
    #         strong "Ano:" do
    #             select do
    #                 intervalo_de_anos(primeira_carteira, ultima_carteira).each do |ano|
    #                     option ano
    #                 end
    #             end
    #         end
    #         div class:"", id: "cart-by-usuarios" do
    #             carteirinhas_by_usuarios_chart carteirinhas_by_usuarios, Carteirinha.where(status_versao_impressa: "Aprovada").count
    #         end
    #     end
    # end   
  end # content
end
