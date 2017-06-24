class CursoSerializer < ActiveModel::Serializer
  attributes :id, :nome, :escolaridade, :escolaridade_id

  def id
  	object.id.to_s if object.id
  end

  def escolaridade
  	object.escolaridade.nome
  end

  def escolaridade_id
  	object.escolaridade.id.to_s if object.escolaridade
  end
  
end
