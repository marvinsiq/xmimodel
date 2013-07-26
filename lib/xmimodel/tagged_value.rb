# encoding: utf-8

require 'xmimodel/tag'

class TaggedValue < Tag

	attr_reader :name
	attr_reader :value

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

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

	def value=(new_value)
		# testar para outros tipos que não sejam o Magic Draw
		tag = @xml.at_xpath("./UML:TaggedValue.dataValue")
		tag.inner_html = new_value
		@value = new_value
	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			return "#{@name}".eql?(obj)
		else
			return @name.eql?(obj.name)
		end
	end	

	def to_s
		"TaggedValue[#{@name}=#{@value}]"
	end	
end