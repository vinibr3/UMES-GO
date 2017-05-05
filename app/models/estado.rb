class Estado < ActiveRecord::Base
 has_many :cidades, -> { order "nome ASC"}

 STRING_REGEX = /\A[A-Z]+\z/
 LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/
  

 validates_presence_of :nome, :sigla
 validates_uniqueness_of :nome, :sigla
 validates_format_of :nome, with: LETRAS
 validates_length_of :nome, in:1..30, wrong_length:"Máximo de 30 carateres."
 validates_format_of :sigla, with: STRING_REGEX
 validates_length_of :sigla, is:2, wrong_length:"Tamanho de #{count} caracteres."

 def self.siglas
 	order(:sigla).map(&:sigla)
 end

end