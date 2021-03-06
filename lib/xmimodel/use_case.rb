# encoding: utf-8

require 'xmimodel/activity_graph'
require 'xmimodel/stereotype'
require 'xmimodel/signal_event'
require 'xmimodel/tag'
require 'xmimodel/tagged_value'

class UseCase < Tag

	attr_reader :package

	attr_reader :name

	attr_reader :stereotypes
	attr_reader :tagged_values

	#UML:CallEvent

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@package = parent_tag.parent_tag

		@name = xml.attribute("name").to_s

		if XmiHelper.has_namespace?(xml)
			namespace = XmiHelper.namespace(xml)		
			@namespace = Namespace.new(namespace, self) unless namespace.nil?
		end			

		stereotype_id = xml.attribute("stereotype").to_s
		if !stereotype_id.empty?
			uml_stereotype = XmiHelper.stereotype_by_id(stereotype_id)
			stereotype = Stereotype.new(uml_stereotype, self)
			@stereotypes << stereotype			
		end
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

	def activity_graphs
		return Array.new if @namespace.nil?
		@namespace.activity_graphs
	end

	def activity_graphs_by_name(name)
		activity_graph = activity_graphs.select{|obj| obj.name == name}
		return activity_graph[0] if !activity_graph.nil? && activity_graph.size > 0
		nil			
	end

	def signal_event_by_name(name)
		signal_event = signal_events.select{|obj| obj.name == name}
		return signal_event[0] if !signal_event.nil? && signal_event.size > 0
		nil			
	end

	def signal_events
		return Array.new if @namespace.nil?
		@namespace.signal_events
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

	def call_events
		return Array.new if @namespace.nil?
		@namespace.call_events
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
		"UseCase[#{full_name}]"
	end
end