
class Parameter
	
	attr_reader :xml
	attr_reader :owner

	attr_reader :id
	attr_reader :name
	attr_reader :kind

	attr_reader :stereotypes
	attr_reader :tagged_values

	def initialize(xml, owner)
		@xml = xml
		@owner = owner

		@id = xml.attribute("xmi:id").to_s
		@name = xml.attribute("name").to_s
		@kind = xml.attribute("kind").to_s

		@stereotypes = Array.new
		XmiHelper.stereotypes(xml).each do |uml_stereotype|
			stereotype = Stereotype.new(uml_stereotype, self)
			@stereotypes << stereotype
		end	

		@tagged_values = Array.new
		XmiHelper.tagged_values(xml).each do |uml_tagged_value|
			tagged_value = TaggedValue.new(uml_tagged_value, self)
			@tagged_values << tagged_value
		end	
	end

	def tagged_value_by_name(tagged_value_name)
		tagged_value = @tagged_values.select{|obj| obj.name == tagged_value_name}
		return tagged_value[0] if !tagged_value.nil? && tagged_value.size > 0
		nil
	end

	def stereotype_by_href(href)
		stereotype = @stereotypes.select{|obj| obj.href == href}
		return stereotype[0] if !stereotype.nil? && stereotype.size > 0
		nil		
	end	

	def full_name
		return "#{@owner.full_name}::#{@kind}" if (@name.nil? || @name.empty?)
		return "#{@owner.full_name}::#{@name}" 		
	end

	def to_s
		"Parameter[#{full_name}]"
	end	
end