# encoding: utf-8

require 'xmimodel/attribute'
require 'xmimodel/stereotype'
require 'xmimodel/tagged_value'
require 'xmimodel/operation'

class Clazz
	
	attr_reader :xml
	
	attr_reader :id
	attr_reader :name
	attr_reader :package
	attr_reader :attributes
	attr_reader :stereotypes
	attr_reader :tagged_values
	attr_reader :operations

	attr_accessor :children
	attr_accessor :parent

	def initialize(xml, parent)
		@xml = xml
		@package = parent.parent
		
		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s.strip
		
		@attributes = Array.new
		XmiHelper.attributes(xml).each do |uml_attribute|
			attribute = Attribute.new(uml_attribute, self)
			@attributes << attribute
		end

		@stereotypes = Array.new
		stereotype_id = xml.attribute("stereotype").to_s
		if !stereotype_id.empty?
			stereotype = XmiHelper.stereotype_by_id(xml, stereotype_id)
			@stereotypes << stereotype.attribute("name").to_s
		end
		XmiHelper.stereotypes(xml).each do |uml_stereotype|
			stereotype = Stereotype.new(uml_stereotype, self)
			@stereotypes << stereotype.name
		end	

		@tagged_values = Array.new
		XmiHelper.tagged_values(xml).each do |uml_tagged_value|
			tagged_value = TaggedValue.new(uml_tagged_value, self)
			@tagged_values << tagged_value
		end

		@operations = Array.new
		XmiHelper.operations(xml).each do |uml_operation|
			tagged_value = Operation.new(uml_operation, self)
			@operations << tagged_value
		end

		# Será povoado quando tratar dos objetos do tipo Genezalization
		@children = Array.new

	end

	def attribute_by_id(attribute_id)
		attribute = @attributes.select{|obj| obj.id == attribute_id}
		return attribute[0] if !attribute.nil? && attribute.size > 0
		nil
	end	

	def attribute_by_name(attribute_name)
		attribute = @attributes.select{|obj| obj.name == attribute_name}
		return attribute[0] if !attribute.nil? && attribute.size > 0
		nil
	end

	def operation_by_name(operation_name)
		operation = @operations.select{|obj| obj.name == operation_name}
		return operation[0] if !operation.nil? && operation.size > 0
		nil
	end	

	def stereotype_by_href(href)
		stereotype = @stereotypes.select{|obj| obj.href == href}
		return stereotype[0] if !stereotype.nil? && stereotype.size > 0
		nil		
	end

	def tagged_value_by_name(tagged_value_name)
		tagged_value = @tagged_values.select{|obj| obj.name == tagged_value_name}
		return tagged_value[0] if !tagged_value.nil? && tagged_value.size > 0
		nil
	end

	def <=>(obj)
    	full_name <=> obj.full_name
	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			full_name == obj
		else
    		full_name == obj.full_name
    	end
	end	

	def full_name
		"#{package.full_name}.#{name}"
	end

	def to_s
		"Clazz[#{full_name}]"
	end	

end