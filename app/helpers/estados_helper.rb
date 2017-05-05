module EstadosHelper
	def self.estados
      http = Net::HTTP.new('raw.githubusercontent.com', 443); http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      JSON.parse http.get('/celsodantas/br_populate/master/states.json').body
  end

  def self.capital?(cidade, estado)
      cidade["name"] == estado["capital"]
  end

  def self.populate
    estados.each do |estado|
      if !Estado.exists?(:sigla => estado["acronym"])   
        estado_obj = Estado.new(:sigla => estado["acronym"], :nome => estado["name"])
        estado_obj.save 
          
        estado["cities"].each do |cidade|
          c = Cidade.new
          c.nome = cidade["name"]
          c.estado = estado_obj
          c.capital = capital?(cidade, estado)
          c.save
        end
      end
    end
  end
end