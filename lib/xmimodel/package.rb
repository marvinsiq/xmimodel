# encoding: utf-8

require 'xmimodel/clazz'
require 'xmimodel/namespace'
require 'xmimodel/tag'
require 'xmimodel/use_case'

class Package < Tag

	attr_reader :name
	attr_reader :full_name
	attr_reader :parent_package

	attr_reader :namespace

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@parent_package = parent_tag.parent_tag unless parent_tag.nil? or parent_tag.class == XmiModel

		@name = xml.attribute("name").to_s
		@full_name = XmiHelper.full_package_name(xml)

		if XmiHelper.has_namespace?(xml)
			namespace = XmiHelper.namespace(xml)		
			@namespace = Namespace.new(namespace, self) unless namespace.nil?
		end

		self		
	end

	def add_xml_class(xml)
		add_namespace() if !XmiHelper.has_namespace?(self.xml)
		@namespace.xml.inner_html = @namespace.xml.inner_html + xml
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

	private 

	def add_namespace
		xml_namespace = XmiHelper.add_namespace(self.xml)
		@namespace = Namespace.new(xml_namespace, self)		
	end
	
end