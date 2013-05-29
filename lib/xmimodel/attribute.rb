require 'xmimodel/stereotype'
require 'xmimodel/tagged_value'

class Attribute

	attr_reader :xml

	attr_reader :id
	attr_reader :name
	attr_reader :type
	attr_reader :visibility
	attr_reader :initial_value
	attr_reader :multiplicity_range
	
	attr_reader :clazz

	attr_reader :stereotypes
	attr_reader :tagged_values

	def initialize(xml, clazz)
		@xml = xml
		@clazz = clazz

		@id = xml.attribute("xmi:id").to_s
		@name = xml.attribute("name").to_s.strip
		@visibility = xml.attribute("visibility").to_s
		@visibility = "private" if @visibility == ""

		@type = XmiHelper.attribute_type_name(xml)

		@initial_value = XmiHelper.attribute_initial_value(xml)
		@multiplicity_range = XmiHelper.multiplicity_range(xml)

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

	def full_name
		"#{@clazz.full_name}::#{@name}"
	end

	def stereotype_by_href(href)
		stereotype = @stereotypes.select{|s| s.href == href}
		return stereotype[0] if !stereotype.nil? && stereotype.size > 0
		nil		
	end

	def tagged_value_by_name(tagged_value_name)
		tagged_value = @tagged_values.select{|t| t.name == tagged_value_name}
		return tagged_value[0] if !tagged_value.nil? && tagged_value.size > 0
		nil			
	end	

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			full_name == obj
		else
    		full_name == obj.full_name
    	end
	end	

	def to_s
		"Attribute[#{full_name}]"
	end	

end