
class DataType

	attr_reader :xml
	attr_reader :parent

	attr_reader :id
	attr_reader :name	
	
	def initialize(xml, parent)
		@xml = xml
		@parent = parent

		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s.strip		
	end

	def to_s
		"DataType[#{@name}]"
	end	
end