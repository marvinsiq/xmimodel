# encoding: utf-8

require 'xmimodel/parameter'
require 'xmimodel/tag'

class Operation < Tag

	attr_reader :name
	attr_reader :visibility

	attr_reader :parameters

	def initialize(xml, parent)
		super(xml, parent)

		@clazz = parent

		@name = xml.attribute("name").to_s
		@visibility = xml.attribute("visibility").to_s
		@visibility = "private" if @visibility == ""
		
		@parameters = Array.new
		XmiHelper.parameters(xml).each do |uml_parameter|
			parameter = Parameter.new(uml_parameter, self)
			@parameters << parameter
		end		
	end

	def parameter_by_name(name)
		parameter = @parameters.select{|obj| obj.name == name}
		return parameter[0] if !parameter.nil? && parameter.size > 0
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

	def full_name
		"#{@clazz.full_name}::#{@name}"
	end

	def to_s
		"Operation[#{full_name}]"
	end	
end