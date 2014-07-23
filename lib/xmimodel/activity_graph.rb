# encoding: utf-8

require 'xmimodel/action_state'
require 'xmimodel/final_state'
require 'xmimodel/pseudo_state'
require 'xmimodel/tag'
require 'xmimodel/transition'

##
# In umbrelo ActivityGraph is not represented by tag 'UML:ActivityGraph'. 
# It's represented by tag diagram inside of XMI.extension.
#
#
class ActivityGraph < Tag

	attr_reader :name

	attr_reader :initial_state
	attr_reader :states
	attr_reader :pseudo_states
	attr_reader :action_states
	attr_reader :final_states
	attr_reader :transitions

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@use_case = parent_tag.parent_tag
		
		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s

		@pseudo_states = Array.new
		XmiHelper.pseudo_states(xml).each do |uml|
			pseudo_state = PseudoState.new(uml, self)
			@pseudo_states << pseudo_state
			@initial_state = pseudo_state if pseudo_state.is_initial_state?
		end

		@action_states = Array.new
		XmiHelper.action_states(xml).each do |uml|
			action_state = ActionState.new(uml, self)
			@action_states << action_state
		end	

		@final_states = Array.new
		XmiHelper.final_states(xml).each do |uml|
			final_state = FinalState.new(uml, self)
			@final_states << final_state
		end

		@transitions = Array.new
		XmiHelper.transitions(xml).each do |uml|
			transition = Transition.new(uml, self)
			@transitions << transition
		end

		@states = @pseudo_states.concat(@action_states).concat(@final_states)

		@states.each do |state|

			state.transitions = transitions_by_source_id(state.id)

			state.transitions.each do |transition|
				transition.source = state			
				
				target = state_by_id(transition.target_id)

				target.from_transitions << transition
				transition.target = target

				state.targets << target
			end
		end
	end

	def full_name
		"#{@use_case.full_name}::#{@name}"
	end

	def to_s
		"ActivityGraph[#{full_name}]"
	end		

	def state_by_name(state_name, name_state=nil)
		if name_state.nil?
			return @states.select{|obj| obj.name == state_name}
		else
			case name_state
				when "PseudoState"
					state = @pseudo_states.select{|obj| obj.name == state_name}
				when "ActionState"
					state = @action_states.select{|obj| obj.name == state_name}
				when "FinalState"
					state = @final_states.select{|obj| obj.name == state_name}
			end
			return state[0] if !state.nil? && state.size > 0
		end
		nil
	end

	def state_by_id(state_id)
		objs = @states.select{|obj| obj.id == state_id}
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end

	def transitions_by_source_id(source)
		objs = @transitions.select{|obj| obj.source_id == source}
	end	

	def transition_by_source_target_ids(source, target)
		objs = @transitions.select{|obj| obj.source == source && obj.target == target}
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end

end