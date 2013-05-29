
class TaggedValue

	attr_reader :xml	

	attr_reader :id
	attr_reader :name
	attr_reader :value

	def initialize(xml, owner)
		@xml = xml
		@owner = owner

		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s

		if @name.nil? or @name.empty?
			tag_definition = XmiHelper.taggeg_value_tag_definition(xml)
			tag_definition_id_ref = tag_definition.attribute("xmi.idref").to_s			
			tag_definition = XmiHelper.tag_definition_by_id(xml, tag_definition_id_ref)
			@name = tag_definition.attribute("name").to_s
		end

		@value = XmiHelper.taggeg_value_data_value(xml)
		@value = XmiHelper.taggeg_value_reference_value(xml) if (@value.nil? || @value.empty?)

	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			return "#{@name}=#{@value}".eql?(obj)
		else
			return @name.eql?(obj.name) && @value.eql?(obj.value)
		end
	end	

	def to_s
		"TaggedValue[#{@name}=#{@value}]"
	end	
end