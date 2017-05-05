module InstituicaoEnsinoHelper

	@@path = "#{Rails.root}/db/seeds/ies"

	def self.populate_todas_instituicoes_ensino ufs
		populate_instituicao_ensino_superior_by_uf ufs
		populate_instituicao_ensino_basico_fundamental_medio_by_uf ufs
	end
	
	def self.populate_instituicao_ensino_superior_by_uf ufs
		populate_instituicao_ensino "#{@@path}/ies_superior.csv", ufs
	end

	def self.populate_instituicao_ensino_basico_fundamental_medio_by_uf ufs
		populate_instituicao_ensino "#{@@path}/ies_basico_fundamental_medio.csv", ufs
	end

	private 
		def self.uf_match_ufs? uf, ufs
			ufs.include?(uf)
		end

		def self.save_instituicao_ensino row
			estado = Estado.find_by_sigla(row[4]);
		    cidade = estado.cidades.where(nome: row[2]).first
		    instituicao = InstituicaoEnsino.new(nome: row[0], sigla: row[1])
		    instituicao.save if instituicao.valid?
		end

		def self.populate_instituicao_ensino file_path, ufs
			CSV.foreach(file_path,{headers: true}) do |row|
			    save_instituicao_ensino row if uf_match_ufs?(row[4], ufs) && !InstituicaoEnsino.exists?(nome: row[0])
	 		end
		end

end