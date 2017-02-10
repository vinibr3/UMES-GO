module ApplicationHelper
	
	def presentation_name nome
		name = ''
		if nome.blank?
			name = current_estudante.email_less_domain	
		else
			name = current_estudante.first_name
		end
		"Olá, #{name}"
	end
end
