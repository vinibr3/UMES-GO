class AvisoSerializer < ActiveModel::Serializer
	attributes :type, :id, :aviso

	def type
		"aviso"
	end
end