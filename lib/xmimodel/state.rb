# encoding: utf-8

require 'xmimodel/tag'

class State < Tag

	attr_reader :activity_graph	

	attr_reader :name

	attr_reader :stereotypes
	attr_reader :tagged_values

	# @return [Transition]
	attr_accessor :from_transition

	# @return [Array<Transition>]
	attr_accessor :transitions

	# @return [Array<State>]
	attr_accessor :targets		

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@activity_graph = parent_tag
		
		@name = xml.attribute("name").to_s

		if @name.nil? || @name.empty?
			
			if xml.name == "Pseudostate"
				if xml.attribute("kind").to_s == "initial"
					@name = "Initial State" 
					@type = :initial_state
				else
					@name = "Decision Point" 
					@type = :decision_point
				end
			end
			@name = "Final State" if xml.name == "FinalState"
		elsif xml.name == "FinalState"
			@name = "#{@name}"
			@type = :final_state
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

		# Serão povoados em ActivityGraph
		@transitions = Array.new
		@targets = Array.new		
	end

	def is_initial_state?
		@type == :initial_state
	end

	def is_decision_point?
		@type == :decision_point
	end

	def is_final_state?
		@type == :final_state
	end

	def is_action_state?
		@type == :action_state
	end

	def path
		if !source().nil?
			source().path + ":" + name
		else
			name
		end
	end

	# @return [State]
	def source
		return nil if from_transition.nil? 
		return from_transition.source
	end	

	def stereotype_by_name(name)
		stereotype = @stereotypes.select{|obj| obj.name == name}
		return stereotype[0] if !stereotype.nil? && stereotype.size > 0
		nil		
	end	

	def tagged_value_by_name(tagged_value_name)
		tagged_value = @tagged_values.select{|obj| obj.name == tagged_value_name}
		return tagged_value[0] if !tagged_value.nil? && tagged_value.size > 0
		nil
	end

	def full_name
		"#{@activity_graph.full_name} {'#{@name}'}"
	end	

	def to_s
		"State[#{full_name}]"
	end
end