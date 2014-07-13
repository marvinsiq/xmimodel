# encoding: utf-8

require 'xmimodel/association'
require 'xmimodel/attribute'
require 'xmimodel/clazz'
require 'xmimodel/data_type'
require 'xmimodel/use_case'
require 'xmimodel/package'
require 'xmimodel/tag'
require 'xmimodel/enumeration'

# UML:Namespace.ownedElement
class Namespace < Tag

	attr_reader :activity_graphs

	# Array of 'UML:Association'
	attr_reader :associations

	# Array of 'UML:Attribute'
	# UML:Attribute is also present in the tag 'UML:Classifier.feature'
	attr_reader :attributes	

	# Array of 'UML:Class'
	attr_reader :classes

	# Array of 'UML:DataType'
	attr_reader :data_types

	# Array of 'UML:UseCase'
	attr_reader :use_cases

	# Array of 'UML:Package'
	attr_reader :packages

	# Array of 'UML:Enumeration'
	attr_reader :enumerations

	# TODO
=begin
	# UML:ModelElement
	attr_reader :model_element

	# UML:GeneralizableElement
	attr_reader :generalizable_element

	# UML:Classifier
	attr_reader :classifier

	# UML:AssociationClass
	attr_reader :association_class

	# UML:Primitive
	attr_reader :Primitive

	# UML:ProgrammingLanguageDataType
	attr_reader :ProgrammingLanguageDataType

	# UML:Interface
	attr_reader :Interface

	# UML:Component
	attr_reader :Component

	# UML:Node
	attr_reader :Node

	# UML:Artifact
	attr_reader :Artifact

	# UML:Signal
	attr_reader :Signal

	# UML:Exception
	attr_reader :Exception

	# UML:Actor
	attr_reader :Actor

	# UML:ClassifierRole
	attr_reader :ClassifierRole

	# UML:ClassifierInState
	attr_reader :ClassifierInState

	# UML:Subsystem
	attr_reader :Subsystem

	# UML:AssociationRole
	attr_reader :AssociationRole

	# UML:Stereotype
	attr_reader :Stereotype

	# UML:Collaboration
	attr_reader :Collaboration

	# UML:Model
	attr_reader :Model

	# UML:Namespace
	attr_reader :Namespace

	# UML:Feature
	attr_reader :Feature

	# UML:StructuralFeature
	attr_reader :StructuralFeature

	# UML:BehavioralFeature
	attr_reader :BehavioralFeature

	# UML:Operation
	attr_reader :Operation

	# UML:Method
	attr_reader :Method

	# UML:Reception
	attr_reader :Reception

	# UML:AssociationEnd
	attr_reader :AssociationEnd

	# UML:AssociationEndRole
	attr_reader :AssociationEndRole

	# UML:Constraint
	attr_reader :Constraint

	# UML:Relationship
	attr_reader :Relationship

	# UML:Generalization
	attr_reader :Generalization

	# UML:Dependency
	attr_reader :Dependency

	# UML:Abstraction
	attr_reader :Abstraction

	# UML:Usage
	attr_reader :Usage

	# UML:Binding
	attr_reader :Binding

	# UML:Permission
	attr_reader :Permission

	# UML:Flow
	attr_reader :Flow

	# UML:Extend
	attr_reader :Extend

	# UML:Include
	attr_reader :Include

	# UML:Parameter
	attr_reader :Parameter

	# UML:Comment
	attr_reader :Comment

	# UML:EnumerationLiteral
	attr_reader :EnumerationLiteral

	# UML:TagDefinition
	attr_reader :TagDefinition

	# UML:TaggedValue
	attr_reader :TaggedValue

	# UML:Instance
	attr_reader :Instance

	# UML:Object
	attr_reader :Object

	# UML:LinkObject
	attr_reader :LinkObject

	# UML:DataValue
	attr_reader :DataValue

	# UML:ComponentInstance
	attr_reader :ComponentInstance

	# UML:NodeInstance
	attr_reader :NodeInstance

	# UML:SubsystemInstance
	attr_reader :SubsystemInstance

	# UML:UseCaseInstance
	attr_reader :UseCaseInstance

	# UML:Action
	attr_reader :Action

	# UML:CreateAction
	attr_reader :CreateAction

	# UML:DestroyAction
	attr_reader :DestroyAction

	# UML:UninterpretedAction
	attr_reader :UninterpretedAction

	# UML:CallAction
	attr_reader :CallAction

	# UML:SendAction
	attr_reader :SendAction

	# UML:ActionSequence
	attr_reader :ActionSequence

	# UML:ReturnAction
	attr_reader :ReturnAction

	# UML:TerminateAction
	attr_reader :TerminateAction

	# UML:AttributeLink
	attr_reader :AttributeLink

	# UML:Link
	attr_reader :Link

	# UML:Argument
	attr_reader :Argument

	# UML:LinkEnd
	attr_reader :LinkEnd

	# UML:Stimulus
	attr_reader :Stimulus

	# UML:ExtensionPoint
	attr_reader :ExtensionPoint

	# UML:StateMachine
	attr_reader :StateMachine

	# UML:ActivityGraph
	attr_reader :ActivityGraph

	# UML:Event
	attr_reader :Event

	# UML:TimeEvent
	attr_reader :TimeEvent

	# UML:CallEvent
	attr_reader :CallEvent

	# UML:SignalEvent
	attr_reader :SignalEvent

	# UML:ChangeEvent
	attr_reader :ChangeEvent

	# UML:StateVertex
	attr_reader :StateVertex

	# UML:State
	attr_reader :State

	# UML:CompositeState
	attr_reader :CompositeState

	# UML:SubmachineState
	attr_reader :SubmachineState

	# UML:SubactivityState
	attr_reader :SubactivityState

	# UML:SimpleState
	attr_reader :SimpleState

	# UML:ActionState
	attr_reader :ActionState

	# UML:CallState
	attr_reader :CallState

	# UML:ObjectFlowState
	attr_reader :ObjectFlowState

	# UML:FinalState
	attr_reader :FinalState

	# UML:Pseudostate
	attr_reader :Pseudostate

	# UML:SynchState
	attr_reader :SynchState

	# UML:StubState
	attr_reader :StubState

	# UML:Transition
	attr_reader :Transition

	# UML:Guard
	attr_reader :Guard

	# UML:Message
	attr_reader :Message

	# UML:Interaction
	attr_reader :Interaction

	# UML:InteractionInstanceSet
	attr_reader :InteractionInstanceSet

	# UML:CollaborationInstanceSet
	attr_reader :CollaborationInstanceSet

	# UML:Partition
	attr_reader :Partition
=end

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@activity_graphs = Array.new
		XmiHelper.activity_graphs(xml).each do |obj|
			activity_graph = ActivityGraph.new(obj, self)
			@activity_graphs << activity_graph
		end		

		@associations = Array.new
		XmiHelper.associations(xml).each do |tag|
			obj = Association.new(tag, self)
			@associations << obj
		end		

		@attributes = Array.new
		XmiHelper.attributes(xml).each do |tag|
			obj = Attribute.new(tag, self)
			@attributes << obj
		end		

		@classes = Array.new
		XmiHelper.classes(xml).each do |tag|
			obj = Clazz.new(tag, self)
			@classes << obj
		end

		@data_types = Array.new
		XmiHelper.data_types(xml).each do |tag|
			obj = DataType.new(tag, self)
			@data_types << obj
		end

		@use_cases = Array.new
		XmiHelper.use_cases(xml).each do |tag|
			obj = UseCase.new(tag, self)
			@use_cases << obj
		end

		@packages = Array.new		
		XmiHelper.packages(xml).each do |tag|
			obj = Package.new(tag, self)
			@packages << obj
		end

		@enumerations = Array.new		
		XmiHelper.enumerations(xml).each do |tag|
			obj = Enumeration.new(tag, self)
			@enumerations << obj
		end	
	end

	def to_s
		"Namespace"
	end 
 end