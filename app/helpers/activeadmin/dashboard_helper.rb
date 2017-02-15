module Activeadmin::DashboardHelper
	def estudantes_pie_3d_chart data, total
		total_formated = number_with_delimiter(total, delimiter: ".")
		manual_percent = (data[0]/total)*100
		site_percent = (data[1]/total)*100
		chart = Gchart.pie_3d(:size => '800x200', :title => "Estudantes Cadastrados (#{total_formated})", 
                                     :data => data , :stacked => false, :bg => 'ffffff', :legend_position => "bottom",
                                     :labels => ["#{manual_percent}%", "#{site_percent}%"], :bar_colors => bar_colors,
                                     :legend => ["Cadastrados por usuários", "Cadastrados pelo site"])
		image_tag  chart, class:'img img-responsive'
	end

	def carteirinhas_pie_3d_chart carteirinhas_count, total
		total_formated = number_with_delimiter(total, delimiter: ".")
		chart = Gchart.pie_3d(:size => '800x200', :title => "Carteirinhas (#{total_formated})", :bg => 'ffffff', :bar_colors => bar_colors,
                                     :data => carteirinhas_count.map{|k,v| v} , :stacked => false, :legend_position => "right",
                                     :labels => carteirinhas_count.map{|k,v| number_to_percentage(v*100/total, precision: 1) if total > 0},
                                     :legend => carteirinhas_count.map{|k,v| k})
		image_tag  chart, class:'img img-responsive'
	end

	def cursos_pie_3d_chart cursos_por_escolaridade, total
		total_formated = number_with_delimiter(total, delimiter: ".")
		chart = Gchart.pie_3d(:size => '800x200', :title => "Cursos por Escolaridade (#{total_formated})", :bg => 'ffffff',
                                     :data => cursos_por_escolaridade.map{|k,v| v} , :stacked => false, :legend_position => "right",
                                     :labels => cursos_por_escolaridade.map{|k,v| number_to_percentage(v*100/total, precision: 1) if total > 0},
                                     :legend => cursos_por_escolaridade.map{|k,v| k.mb_chars.titleize}, :bar_colors => bar_colors)
		image_tag  chart, class:'img img-responsive'
	end

	def carteirinhas_by_usuarios_chart carteirinhas_by_usuarios, total
		total_formated = number_with_delimiter(total, delimiter: ".")
		chart = Gchart.line(:size => '800x200', :title => "Carteiras Aprovadas por Usuarios (#{total_formated})", :bg => 'ffffff',
                                     :data => carteirinhas_by_usuarios.map{|k,v| v} , :stacked => false, :legend_position => "right",
                                     :labels => carteirinhas_by_usuarios.map{|k,v| number_to_percentage(v*100/total, precision: 1) if total > 0},
                                     :legend => carteirinhas_by_usuarios.map{|k,v| k.mb_chars.titleize}, :bar_colors => bar_colors,
                                     :axis_labels => ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'], 
                    				 :axis_range => [[0,100,20], [0,20,5]])
		image_tag  chart, class:'img img-responsive'
	end

	def intervalo_de_anos primeira_carteira, ultima_carteira
		anos = Array.new
		if primeira_carteira && ultima_carteira
			anos.add('Todos')
			anos.add(ultima_carteira.aprovada_em.year)
			
			diferenca_de_anos = ultima_carteira.aprovada_em.year - primeira_carteira.aprovada_em.year
			diferenca_de_anos.times do
				anos.add(anos.last-1)
			end if diferenca_de_anos >= 0
		end
		anos
	end

	private 
		def bar_colors
			['15458c','faa417','066034','ff0000','ff00ff','0000ff','00ffff','00ff00','ffff00','7f0000',
			'7f007f','00007f','007f7f','007f00','827f00','000000','191919','333333','4c4c4c','4c4c4c']
		end
end