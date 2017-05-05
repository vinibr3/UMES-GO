module EscolaridadesHelper

	@@path = "#{Rails.root}/db/seeds/escolaridades"

	def self.populate
		file_path = "#{@@path}/escolaridades.csv"
		CSV.foreach(file_path,{headers: true}) do |row|
			save_escolaridade row[0] if !Escolaridade.exists?(nome: row[0])
	 	end
	end

	private 
		def self.save_escolaridade nome
			escolaridade = Escolaridade.new(nome: nome)
			escolaridade.save if escolaridade.valid?
		end
end