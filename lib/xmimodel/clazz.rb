# encoding: utf-8

require 'xmimodel/attribute'
require 'xmimodel/operation'
require 'xmimodel/tag'
require 'xmimodel/tagged_value'
require 'xmimodel/stereotype'

class Clazz < Tag
	
	attr_reader :name

	# @return [String] Full Package name of class.
	attr_reader :package

	# @return [Array<Attribute>] Class attributes.
	attr_reader :attributes

	# @return [Array<Stereotype>] Class stereotypes.
	attr_reader :stereotypes

	# @return [Array<TaggedValue>] Class tagged values.
	attr_reader :tagged_values
	
	attr_reader :operations

	# @return [Array<Clazz>] Return the child classes when has inheritance.
	attr_accessor :children

	# @return [Clazz] Return the parent class when has inheritance.
	attr_accessor :parent

	# @return [Array<Association>] Class associations.
	attr_reader :associations

	# @return [Array<AssociationEnd>] Class associations end.
	attr_reader :associations_end	

	def initialize(xml, parent_tag)		
		super(xml, parent_tag)

		@package = parent_tag.parent_tag
				
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
			stereotype = Stereotype.new(stereotype, self)
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

		@operations = Array.new
		XmiHelper.operations(xml).each do |uml_operation|
			tagged_value = Operation.new(uml_operation, self)
			@operations << tagged_value
		end

		# Será povoado quando tratar dos objetos do tipo Genezalization
		@children = Array.new

		@associations = Array.new
		@associations_end = Array.new

	end

	def add_xml_attribute(xml_attribute)
		parent = self.xml.at_xpath('./UML:Classifier.feature')
		if parent.nil?
			parent = Nokogiri::XML::Node.new('Classifier.feature', self.xml.document)
			self.xml << parent
		end		
		parent.inner_html = parent.inner_html + xml_attribute

		@attributes << Attribute.new(uml_attribute, self)		
	end

	##
	# @param xml [Nokogiri::XML::Element, #read]
	def add_xml_stereotype(xml)		
		parent = self.xml.at_xpath('./UML:ModelElement.stereotype')
		if parent.nil?
			parent = Nokogiri::XML::Node.new('ModelElement.stereotype', self.xml.document)
			self.xml << parent
		end		
		parent.inner_html = parent.inner_html + xml.to_xml

		stereotype = Stereotype.new(xml, self)
		@stereotypes << stereotype
		return stereotype
	end

	##
	# @param [String, #read] associations_end_name 
	# @param [Clazz, #read] participant
	# @return [AssociationEnd]	
	def association_end_by_name_and_participant(associations_end_name, participant)
		obj = @associations_end.select{|obj| obj.name == associations_end_name && obj.participant == participant}
		return obj[0] if !obj.nil? && obj.size > 0
		nil
	end	

	##
	# @param [Clazz, #read] participant
	# @return [Array<AssociationEnd>]
	def associations_end_by_participant(participant)
		obj = @associations_end.select{|obj| obj.participant == participant}
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

	def stereotype_by_name(name)
		stereotype = @stereotypes.select{|obj| obj == name}
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