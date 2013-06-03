
class Stereotype

	attr_reader :xml	
	attr_reader :href

	def initialize(xml, owner)
		@xml = xml
		@owner = owner

		@id = xml.attribute("xmi.id").to_s
		@name = xml.attribute("name").to_s
		@href = xml.attribute("href").to_s
		@idref = xml.attribute("xmi.idref").to_s
	end

	def <=>(obj)
    	name <=> obj.name
	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			name == obj
		else
    		name == obj.name
    	end
	end	

	def name
		return @name unless (@name.nil? or @name.empty?)

		@name = XmiHelper.extension_referent_path_value(xml)
		
		if @name.empty?		
			# Se 'xmi.idref' não for null, o documento irá apontar para o id de outra tag 
			# UML:Stereotype (que estará dentro de UML:Namespace.ownedElement e não UML:ModelElement.stereotype)
			id = @idref.empty? ? @href : @idref
			xml = XmiHelper.stereotype_by_id(@xml, id)
			if !xml.nil?
				@id = xml.attribute("xmi.id").to_s
				@name = xml.attribute("name").to_s
				@isSpecification = xml.attribute("isSpecification").to_s
				@isRoot = xml.attribute("isRoot").to_s
				@isLeaf = xml.attribute("isLeaf").to_s
				@isAbstract = xml.attribute("isAbstract").to_s			
			end	
		end
			
		if @name.empty?
			App.logger.warn "Stereotype not found. Id: #{@id}"
			@name = @href
		end	

		@name
	end

	def to_s
		"Stereotype[#{name}]"
	end
end