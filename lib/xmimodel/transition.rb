# encoding: utf-8

require 'xmimodel/stereotype'
require 'xmimodel/tag'
require 'xmimodel/tagged_value'

class Transition < Tag

	attr_reader :activity_graph

	attr_reader :trigger_id
	attr_reader :source_id
	attr_reader :target_id

	# Será povoado em ActivityGraph
	attr_accessor :trigger
	attr_accessor :source
	attr_accessor :target	

	attr_reader :stereotypes
	attr_reader :tagged_values

	attr_reader :guard_condition

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@activity_graph = parent_tag
		
		@trigger_id = xml.attribute("trigger").to_s
		@source_id = xml.attribute("source").to_s
		@target_id = xml.attribute("target").to_s

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

		guard_condition = XmiHelper.guard_condition(xml)
		@guard_condition = guard_condition.attribute("body").to_s unless guard_condition.nil?
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

	def full_name
		source_name = @source.nil? ? "" : @source.name
		target_name = @target.nil? ? "" : @target.name
		"#{@activity_graph.full_name} ('#{source_name}' --> '#{target_name}')"
	end

	def to_s
		"Transition[#{full_name}]"
	end
end