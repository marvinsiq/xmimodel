
class Association

	attr_reader :xml
	attr_reader :parent

	attr_reader :id
	attr_reader :name
	
	# TODO Build AssociationEnd class
	def initialize(xml, parent)
		@xml = xml
		@parent = parent

		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s.strip

		#association_end_a
		#association_end_b
	end

	def to_s
		"Association[#{@name}]"
	end	
	
end