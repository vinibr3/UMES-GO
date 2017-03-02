module PagesHelper
	def button_solicitacao_helper
		if estudante_signed_in?
			link_to 'Solicitar agora', estudante_path(current_estudante)
		else
			link_to 'Solicitar agora', new_estudante_registration_path
		end
	end
end
