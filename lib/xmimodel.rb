# encoding: utf-8

require File.join(File.dirname(__FILE__), 'xmimodel/package.rb')
require File.join(File.dirname(__FILE__), 'xmimodel/generalization.rb')
require File.join(File.dirname(__FILE__), 'xmimodel/xmihelper.rb')

class XmiModel

	attr_reader :document

	# Header
	attr_reader :exporter
	attr_reader :exporter_version
	attr_reader :metamodel_version

	attr_reader :generalizations
	attr_reader :associations

	##
	# Construtor. 
	# 
	# Recebe como parâmetro o caminho completo do modelo (arquivo xml, xmi...)
	def initialize(model_file_name)

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
				p = Package.new(uml_package, nil)
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

		@associations = Array.new
		XmiHelper.all_associations(xmi_content).each do |xml|
			@associations << Association.new(xml, self)
		end

		true
	end

	def class_by_full_name(full_class_name)
		raise ArgumentError.new("Parameter 'full_class_name' cannot be empty.") if full_class_name.nil? or full_class_name.empty?
		clazz = classes.select{|c| c.full_name == full_class_name}
		
		if !clazz.nil? && clazz.size > 0
			clazz[0]
		else
			nil
		end
	end

	def class_by_id(class_id)
		raise ArgumentError.new("#{__method__}: 'class_id' cannot be empty.") if class_id.nil? or class_id.empty?
		clazz = classes.select{|c| c.id == class_id}
		
		if !clazz.nil? && clazz.size > 0
			clazz[0]
		else
			nil
		end
	end	

	def classes
		return @classes unless @classes.nil?
		@classes = Array.new
		packages.each do |p|
			@classes.concat p.classes.sort
		end
		@classes
	end

	def package_by_full_name(full_package_name)
		raise ArgumentError.new("Parameter 'full_package_name' cannot be empty.") if full_package_name.nil? or full_package_name.empty?
		package = packages.select{|p| p.full_name == full_package_name}
		
		if !package.nil? && package.size > 0
			package[0]
		else
			nil
		end
	end	

	def packages
		return @all_packages unless @all_packages.nil?
		@all_packages = Array.new

		add_package(@packages)
		
		@all_packages.sort!
		@all_packages
	end

	def state_by_id(id)
		raise ArgumentError.new("Parameter 'id' cannot be empty.") if id.nil? or id.empty?
		objs = states.select{|obj| obj.id == id}	
		(!objs.nil? && objs.size > 0) ? objs[0] : nil
	end

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

	def to_s
		"'XmiModel #{exporter} #{exporter_version} [Packages: #{packages.size}, Classes: #{classes.size}]'"
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