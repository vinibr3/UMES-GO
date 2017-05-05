class InstituicaoEnsinoSerializer < ActiveModel::Serializer
  ActiveModel::Serializer.root = false
  attributes :id, :nome, :sigla, :cidade, :estado

  def cidade 
  	object.cidade.nome if object.cidade
  end

  def estado
  	object.estado.nome if object.estado
  end

end
