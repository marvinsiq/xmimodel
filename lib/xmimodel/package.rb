# encoding: utf-8

require 'xmimodel/clazz'
require 'xmimodel/use_case'
require 'xmimodel/namespace'

class Package

	attr_reader :xml

	attr_reader :name
	attr_reader :full_name
	attr_reader :parent_package

	attr_reader :namespace

	def initialize(xml, parent)

		@xml = xml
		@parent_package = parent.parent unless parent.nil?

		@name = xml.attribute("name").to_s
		@full_name = XmiHelper.full_package_name(xml)

		if XmiHelper.has_namespace?(xml)
			namespace = XmiHelper.namespace(xml)		
			@namespace = Namespace.new(namespace, self) unless namespace.nil?
		else
			puts "[WARN] Package '#{@name}' does not have namespace."
		end

		self		
	end

	def activity_graphs
		return Array.new if @namespace.nil?
		@namespace.activity_graphs
	end	

	def classes
		return Array.new if @namespace.nil?
		@namespace.classes
	end

	def class_by_name(name)
		return nil if @namespace.nil?
		clazz = @namespace.classes.select{|c| c.name == name}
		return clazz[0] if !clazz.nil? && clazz.size > 0
		nil
	end

	def packages
		return Array.new if @namespace.nil?
		@namespace.packages
	end

	def use_cases
		return Array.new if @namespace.nil?
		@namespace.use_cases
	end

	def use_case_by_name(name)
		return nil if @namespace.nil?
		use_case = @namespace.use_cases.select{|u| u.name == name}
		return use_case[0] if !use_case.nil? && use_case.size > 0
		nil
	end	

	def <=>(obj)
    	@full_name <=> obj.full_name
	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			@full_name == obj
		else
    		@full_name == obj.full_name
    	end
	end

	def to_s
		"Package[#{@full_name}]"
	end	
	
end