class InstituicaoEnsinoSerializer < ActiveModel::Serializer
  ActiveModel::Serializer.root = false
  attributes :id, :nome, :sigla, :cidade, :cidade_id, :estado, :cidade_estado

  def id
  	object.id.to_s if object.id
  end

  def cidade 
  	object.cidade.nome if object.cidade
  end

  def cidade_id
    object.cidade.id.to_s if object.cidade
  end

  def estado
  	object.estado.sigla if object.estado
  end

end
