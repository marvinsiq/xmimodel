
class State

	attr_reader :xml
	attr_reader :activity_graph	

	attr_reader :id
	attr_reader :name

	attr_reader :stereotypes
	attr_reader :tagged_values	

	def initialize(xml, activity_graph)
		@xml = xml
		@activity_graph = activity_graph
		
		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s

		if @name.nil? || @name.empty?
			
			if xml.name == "Pseudostate"
				if xml.attribute("kind").to_s == "initial"
					@name = "Initial State" 
				else
					@name = "Decision Point" 
				end
			end
			@name = "Final State" if xml.name == "FinalState"
		elsif xml.name == "FinalState"
			@name = "Final State [#{@name}]"
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

	def full_name
		"#{@activity_graph.full_name} {'#{@name}'}"
	end	

	def to_s
		"State[#{full_name}]"
	end
end