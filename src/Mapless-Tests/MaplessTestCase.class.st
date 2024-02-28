Class {
	#name : #MaplessTestCase,
	#superclass : #TestCase,
	#category : #'Mapless-Tests-Tests'
}

{ #category : #tests }
MaplessTestCase >> testGetterReturn [
	| guy |
	guy := DummyPerson new.
	self assert: guy firstName isNil.
	guy firstName: 'John'.
	self assert: guy firstName notNil.
	self assert: guy firstName equals: 'John'
]

{ #category : #tests }
MaplessTestCase >> testSetterReturn [
	| guy set |
	guy := DummyPerson new.
	self assert: guy firstName isNil.
	set := guy firstName: 'John'.
	self assert: set equals: guy.
	self assert: guy firstName notNil.
	self assert: guy firstName equals: 'John'
]
