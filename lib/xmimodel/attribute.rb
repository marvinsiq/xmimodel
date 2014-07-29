# encoding: utf-8

require 'xmimodel/stereotype'
require 'xmimodel/tag'
require 'xmimodel/tagged_value'

class Attribute < Tag

	attr_reader :name
	attr_reader :type
	attr_reader :visibility
	attr_reader :initial_value
	attr_reader :multiplicity_range
	
	attr_reader :clazz

	attr_reader :stereotypes
	attr_reader :tagged_values

	def initialize(xml, parent_tag)
		super(xml, parent_tag)
		
		@clazz = parent_tag

		@name = xml.attribute("name").to_s.strip
		@visibility = xml.attribute("visibility").to_s
		@visibility = "private" if @visibility == ""

		@obj_type = XmiHelper.attribute_type(xml)
		@type = XmiHelper.attribute_type_name(xml)

		#puts "Atributo:: "+ @name
		#puts "Obj Type: "+ @obj_type
		#puts "Type: "+ @type

		@initial_value = XmiHelper.attribute_initial_value(xml)
		@multiplicity_range = XmiHelper.multiplicity_range(xml)

		@stereotypes = Array.new
		stereotype_id = xml.attribute("stereotype").to_s
		if !stereotype_id.empty?
			uml_stereotype = XmiHelper.stereotype_by_id(xml, stereotype_id)
			stereotype = Stereotype.new(uml_stereotype, self)
			@stereotypes << stereotype			
		end		
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

	def add_xml_tagged_value(xml)
		model_element_tagged_value().inner_html = model_element_tagged_value().inner_html + xml
	end

=begin
	def add_tagged_value(name, value)		
		if tagged_values.include? name
			tag = tagged_value_by_name name
		else
			tagged_value = Nokogiri::XML::Node.new('TaggedValue', self.xml.document)
			tagged_value['xmi.id'] = 
			tagged_value['name'] = name
			model_element_tagged_value() << tagged_value			
		end
		tag.value = value
	end
=end

	def is_enum?
		return false if @obj_type.nil?
		if @obj_type.class == Nokogiri::XML::Element
			
			if @obj_type.name == "Enumeration"
				id = @obj_type.attribute('xmi.id').to_s
				@enum_obj = xml_root.enumeration_by_id(id)
				return true 
			end

			if @obj_type.name == "Class"
				id = @obj_type.attribute('xmi.id').to_s
				@enum_obj = xml_root.class_by_id(id)
				return @enum_obj.stereotypes.include?("org.andromda.profile::Enumeration")
			end
		end		
		false		
	end

	def enum_obj
		return @enum_obj unless @enum_obj.nil?
		is_enum?()
		@enum_obj
	end

	def full_name
		"#{@clazz.full_name}::#{@name}"
	end

	def stereotype_by_name(name)
		stereotype = @stereotypes.select{|s| s.name == name}
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

	private

	def model_element_tagged_value
		return @model_element_tagged_value unless @model_element_tagged_value.nil?
		@model_element_tagged_value = self.xml.at_xpath('./UML:ModelElement.taggedValue')
		if @model_element_tagged_value.nil?
			@model_element_tagged_value = Nokogiri::XML::Node.new('ModelElement.taggedValue', self.xml.document)
			self.xml << model_element_tagged_value
		end
		@model_element_tagged_value
	end

end