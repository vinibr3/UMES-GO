module CursosHelper
	
	@@path = "#{Rails.root}/db/seeds/cursos"

	def self.populate_todos_cursos
		populate_cursos_basico
		populate_cursos_fundamental
		populate_cursos_medio
		populate_cursos_pre_vestibular
		populate_cursos_graduacao
		populate_cursos_pos_graduacao
		populate_cursos_mestrado
		populate_cursos_doutorado
		populate_cursos_pos_doutorado
		populate_cursos_graduacao
		populate_cursos_tecnicos
		populate_cursos_tecnologos
		populate_cursos_profissionalizantes
	end

	def self.populate_cursos_basico
		ensino_infantil = Escolaridade.find_by_nome("ENSINO INFANTIL")
		save_curso "BERÇARIO", ensino_infantil
		save_curso "MATERNAL", ensino_infantil
	end

	def self.populate_cursos_fundamental
		ensino_fundamental = Escolaridade.find_by_nome("ENSINO FUNDAMENTAL")
		 9.times do |i|
		 	nome_curso = (i+1).to_s.concat("º ANO")
		 	save_curso nome_curso, ensino_fundamental
		 end
	end

	def self.populate_cursos_medio
		ensino_medio = Escolaridade.find_by_nome("ENSINO MÉDIO")
 		3.times do |i|
 			nome_curso = (i+1).to_s.concat("º ANO")
 			save_curso nome_curso, ensino_medio
 		end
	end

	def self.populate_cursos_tecnicos
		curso_tecnico = Escolaridade.find_by_nome("ENSINO TÉCNICO")
		populate_cursos "#{@@path}/cursos_tecnicos.csv", curso_tecnico
	end

	def self.populate_cursos_tecnologos
		tecnologos = Escolaridade.find_by_nome("TECNÓLOGO")
		populate_cursos "#{@@path}/cursos_tecnologos.csv", tecnologos
	end

	def self.populate_cursos_profissionalizantes
		# Mesmos cursos do ensino técnico
		profissionalizante = Escolaridade.find_by_nome("ENSINO PROFISSIONALIZANTE")
		populate_cursos "#{@@path}/cursos_tecnicos.csv", profissionalizante
	end

	def self.populate_cursos_pre_vestibular
		pre_vestibular = Escolaridade.find_by_nome("PRÉ-VESTIBULAR")
		populate_cursos "#{@@path}/cursos_pre_vestibular.csv", pre_vestibular
	end

	def self.populate_cursos_graduacao
		graduacao = Escolaridade.find_by_nome("GRADUAÇÃO")
		populate_cursos "#{@@path}/cursos_superior.csv", graduacao
	end

	def self.populate_cursos_mestrado
		mestrado = Escolaridade.find_by_nome("PÓS-GRADUAÇÃO")
		populate_cursos "#{@@path}/cursos_superior.csv", mestrado
	end

	def self.populate_cursos_pos_graduacao
		pos_graduacao = Escolaridade.find_by_nome("PÓS-GRADUAÇÃO")
		populate_cursos "#{@@path}/cursos_superior.csv", pos_graduacao
	end

	def self.populate_cursos_mestrado
		mestrado = Escolaridade.find_by_nome("MESTRADO")
		populate_cursos "#{@@path}/cursos_superior.csv", mestrado
	end

	def self.populate_cursos_doutorado
		doutorado = Escolaridade.find_by_nome("DOUTORADO")
		populate_cursos "#{@@path}/cursos_superior.csv", doutorado
	end

	def self.populate_cursos_pos_doutorado
		pos_doutorado = Escolaridade.find_by_nome("PÓS-DOUTORADO")
		populate_cursos "#{@@path}/cursos_superior.csv", pos_doutorado
	end

	private 
		def self.save_curso nome, escolaridade
			curso = Curso.new(nome: nome, escolaridade: escolaridade)
			curso.save if curso.valid? && !Curso.exists?(nome: nome, escolaridade: escolaridade)
		end

		def self.populate_cursos file_path, escolaridade
			CSV.foreach(file_path,{headers: true}) do |row|
			    save_curso row[0], escolaridade if !Curso.exists?(nome: row[0], escolaridade: escolaridade)
	 		end if escolaridade
		end
end