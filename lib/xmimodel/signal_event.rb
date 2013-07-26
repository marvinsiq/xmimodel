# encoding: utf-8

require 'xmimodel/parameter'
require 'xmimodel/tag'

class SignalEvent < Tag

	attr_reader :name

	attr_reader :parameters

	attr_reader :use_case

	def initialize(xml, parent_tag)
		super(xml, parent_tag)
		@use_case = parent_tag.parent_tag

		@name = xml.attribute("name").to_s

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

	def full_name
		"#{use_case.full_name}::#{name}"
	end

	def to_s
		"SignalEvent[#{full_name}]"
	end
end