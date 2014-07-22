# encoding: utf-8

require File.join(File.dirname(__FILE__), 'xmimodel/package.rb')
require File.join(File.dirname(__FILE__), 'xmimodel/generalization.rb')
require File.join(File.dirname(__FILE__), 'xmimodel/xmihelper.rb')

##
# A helper class for working with XMI Models.
class XmiModel

	# @return [Nokogiri::XML::Document]
	attr_reader :document

	# @return [String] The contents of the tag 'XMI.header/XMI.documentation/XMI.exporter'.
	attr_reader :exporter

	# @return [String] The contents of the tag 'XMI.header/XMI.documentation/XMI.exporterVersion'.
	attr_reader :exporter_version

	# @return [String] The value of property xmi.version of the tag 'XMI.header/XMI.metamodel'.
	attr_reader :metamodel_version

	# @return [Array<Generalization>] All model generalizations.
	attr_reader :generalizations
	
	# @return [Array<Association>] All model associations.
	attr_reader :associations

	attr_reader :model_file_name

	##
	# Constructor. 
	# 
	# @param [String, #read] Path of model.
	def initialize(model_file_name)

		@model_file_name = model_file_name

		# Obtem a tag 'XMI.content' que contém todos os objetos que serão tratados
		f = File.open(model_file_name)		
		doc = Nokogiri::XML(f)
		@document = doc
		xmi_content = doc.at_xpath("./XMI/XMI.content")
		f.close

		# Header
		@exporter = XmiHelper.exporter(doc)
		@exporter_version = XmiHelper.exporter_version(doc)
		@metamodel_version = XmiHelper.metamodel_version(doc)

		# Constrói vetor de pacotes
		@packages = Array.new		
		XmiHelper.packages(xmi_content).each do |uml_package|
			if ! (uml_package.attribute('name').nil? || 
				uml_package.attribute('name').to_s.empty? || 
				uml_package.attribute('name').to_s.strip == "Component View" ||
				uml_package.attribute('name').to_s.strip == "Data types")
				p = Package.new(uml_package, self)
				@packages << p
			end
		end

		# Constrói vetor de heranças
		@generalizations = Array.new
		XmiHelper.all_generalizations(xmi_content).each do |xml|
			g = Generalization.new(xml, self)
			
			g.child_obj.parent  = g.parent_obj unless g.child_obj.nil?
			g.parent_obj.children << g.child_obj unless g.parent_obj.nil?

			#puts "#{g.child_obj.full_name} - #{g.parent_obj.full_name}"
			@generalizations << g
		end

		# Constroi vetor de associações
		@associations = Array.new
		XmiHelper.all_associations(xmi_content).each do |xml|

			association = Association.new(xml, self)
			
			association.end_a.participant.associations << association	
			association.end_b.participant.associations << association

			association.end_a.other_end = association.end_b
			association.end_b.other_end = association.end_a

			association.end_a.participant.associations_end << association.end_b	
			association.end_b.participant.associations_end << association.end_a			

			@associations << association
		end

		# Associa os signal events aos action states 
		use_cases().each do |use_case|
			use_case.activity_graphs.each do |activity_graph|
				activity_graph.states.each do |state|
					state.transitions.each do |transition|
						trigger_id = transition.trigger_id
						if !trigger_id.empty?
							signal_event = signal_event_by_id(trigger_id)
							transition.trigger = signal_event
						end
					end
				end
			end
		end

		call_events().each do |call_event|
			operation = operation_by_id(call_event.operation_id)
			call_event.operation = operation
		end			

		# Associa o deferrable_event dos action states aos call events
		states().each do |state|
			if state.is_action_state? && (!state.deferrable_event_id.nil? && !state.deferrable_event_id.empty?)
				call_event = call_event_by_id(state.deferrable_event_id)
				state.deferrable_event = call_event
			end
		end

		true
	end

	##
	# Get the object of type 'Association' by id.
	#
	# @param [String, #read] Id of the state in model file.
	# @return [Association]
	def association_by_id(id)
		raise ArgumentError.new("Parameter 'id' cannot be empty.") if id.nil? or id.empty?
		objs = @associations.select{|obj| obj.id == id}	
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end	

	##
	# Get the object of type 'Clazz' by full name of class.
	#
	# @param [String, #read] Name of the class including package name.
	# @return [Clazz]
	def class_by_full_name(full_class_name)
		raise ArgumentError.new("Parameter 'full_class_name' cannot be empty.") if full_class_name.nil? or full_class_name.empty?
		clazz = classes.select{|c| c.full_name == full_class_name}
		
		if !clazz.nil? && clazz.size > 0
			clazz[0]
		else
			nil
		end
	end

	##
	# Get the object of type 'Clazz' by id.
	#
	# @param [String, #read] Id of the class in model file.
	# @return [Clazz]
	def class_by_id(class_id)
		raise ArgumentError.new("#{__method__}: 'class_id' cannot be empty.") if class_id.nil? or class_id.empty?
		clazz = classes.select{|c| c.id == class_id}
		
		if !clazz.nil? && clazz.size > 0
			clazz[0]
		else
			nil
		end
	end	

	##
	# Get all model classes.
	#
	# @return [Array<Clazz>]
	def classes
		return @classes unless @classes.nil?
		@classes = Array.new
		packages.each do |p|
			@classes.concat p.classes.sort
		end
		@classes
	end

	##
	# Get all model enumerations.
	#
	# @return [Array<Enumeration>]
	def enumerations
		return @enumerations unless @enumerations.nil?
		@enumerations = Array.new
		packages.each do |p|
			@enumerations.concat p.enumerations.sort
		end
		@enumerations
	end	

	##
	# Get the object of type 'Package' by full name of package.
	#
	# @param [String, #read] Name of the package including sub packages name.
	# @return [Package]
	def package_by_full_name(full_package_name)
		raise ArgumentError.new("Parameter 'full_package_name' cannot be empty.") if full_package_name.nil? or full_package_name.empty?
		package = packages.select{|p| p.full_name == full_package_name}
		
		if !package.nil? && package.size > 0
			package[0]
		else
			nil
		end
	end	

	##
	# Get all model packages.
	#
	# @return [Array<Package>]
	def packages
		return @all_packages unless @all_packages.nil?
		@all_packages = Array.new

		add_package(@packages)
		
		@all_packages.sort!
		@all_packages
	end

	##
	# Get the object of type 'State' by id.
	#
	# @param [String, #read] Id of the state in model file.
	# @return [ActionState, FinalState, PseudoState]
	def state_by_id(id)
		raise ArgumentError.new("Parameter 'id' cannot be empty.") if id.nil? or id.empty?
		objs = states.select{|obj| obj.id == id}	
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end


	##
	# Get all model states.
	#
	# @return [Array<ActionState, FinalState, PseudoState>]
	def states
		return @states unless @states.nil?

		@states = Array.new
		packages.each do |p|
			p.use_cases.each do |u|
				u.activity_graphs.each do |a|
					@states.concat a.action_states
					@states.concat a.final_states
					@states.concat a.pseudo_states
				end
			end
			p.activity_graphs.each do |a|
				@states.concat a.action_states
				@states.concat a.final_states
				@states.concat a.pseudo_states
			end			
		end
		@states		
	end

	def signal_events
		return @signal_events unless @signal_events.nil?

		@signal_events = Array.new
		packages().each do |p|
			@signal_events.concat p.signal_events.sort
		end
		use_cases().each do |p|
			@signal_events.concat p.signal_events.sort
		end
		@signal_events		
	end

	##
	# Get the object of type 'SignalEvent' by id.
	#
	# @param [String, #read] Id of the SignalEvent in model file.
	# @return [SignalEvent]
	def signal_event_by_id(signal_event_id)
		raise ArgumentError.new("#{__method__}: 'signal_event_id' cannot be empty.") if signal_event_id.nil? or signal_event_id.empty?
		signal_event = signal_events.select{|obj| obj.id == signal_event_id}
		
		if !signal_event.nil? && signal_event.size > 0
			signal_event[0]
		else
			nil
		end
	end		


	def id_exists?(id)
		tag = XmiHelper.tag_by_id(@document, '*', id)
		return !tag.nil?
	end	

	def to_s
		"'XmiModel #{exporter} #{exporter_version} [Packages: #{packages.size}, Classes: #{classes.size}]'"
	end

	def to_xml
		@document.to_xml
	end

	##
	# Get all Use Case.
	#
	# @return [Array<UseCase>]
	def use_cases
		return @use_cases unless @use_cases.nil?
		@use_cases = Array.new
		packages.each do |p|
			@use_cases.concat p.use_cases.sort
		end
		@use_cases
	end

	##
	# Get all Call Events.
	#
	# @return [Array<CallEvent>]
	def call_events
		return @call_events unless @call_events.nil?
		@call_events = Array.new
		use_cases.each do |c|
			@call_events.concat c.call_events
		end
		@call_events
	end

	##
	# Get the object of type 'CallEvent' by id.
	#
	# @param [String, #read] Id of the CallEvent in model file.
	# @return [CallEvent]
	def call_event_by_id(id)		
		raise ArgumentError.new("Parameter 'id' cannot be empty.") if id.nil? or id.empty?
		objs = call_events().select{|obj| obj.id == id}	
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end

	##
	# Get all Operations
	#
	# @return [Array<Operation>]
	def operations
		return @operations unless @operations.nil?
		@operations = Array.new
		classes.each do |c|
			@operations.concat c.operations
		end
		@operations
	end

	##
	# Get the object of type 'Operation' by id.
	#
	# @param [String, #read] Id of the Operation in model file.
	# @return [Operation]
	def operation_by_id(id)		
		raise ArgumentError.new("Parameter 'id' cannot be empty.") if id.nil? or id.empty?
		objs = operations().select{|obj| obj.id == id}	
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end	

	def save(model_file_name=@model_file_name)
		f = File.open(model_file_name, 'w')
		f.write(@document.to_xml)
		f.close		
	end

	private
	
	def add_package(packages)
		packages.each do |p|
			#puts p.name
			@all_packages << p			
			add_package(p.packages) unless p.packages.nil?
		end
	end

end