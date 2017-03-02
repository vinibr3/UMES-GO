class ContatoMailer < ApplicationMailer
	layout 'mailer'
	def contato_mensagem(contato)
		@contato = contato
		mail(:to => ENV["STUDENTCASYSTEM_EMAIL_FORM_RECEIVER"], :subject => contato.assunto)
	end
end
