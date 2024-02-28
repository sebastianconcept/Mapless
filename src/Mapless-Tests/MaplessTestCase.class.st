Class {
	#name : #MaplessTestCase,
	#superclass : #TestCase,
	#category : #'Mapless-Tests-Tests'
}

{ #category : #tests }
MaplessTestCase >> testGetterReturn [
	| guy |
	guy := SamplePerson new.
	self assert: guy firstName isNil.
	guy firstName: 'John'.
	self assert: guy firstName notNil.
	self assert: guy firstName equals: 'John'
]

{ #category : #tests }
MaplessTestCase >> testPoolBasics [

	| pool |
	pool := MaplessAbstractPool
		        hostname: '1'
		        port: 2
		        username: '3'
		        password: '4'.

	self assert: pool hostname equals: '1'.
	self assert: pool port equals: 2.
	self assert: pool username equals: '3'.
	self assert: pool password equals: '4'.

	pool := MaplessAbstractPool hostname: '1' port: 2.

	self assert: pool hostname equals: '1'.
	self assert: pool port equals: 2
]

{ #category : #tests }
MaplessTestCase >> testSetterReturn [
	| guy set |
	guy := SamplePerson new.
	self assert: guy firstName isNil.
	set := guy firstName: 'John'.
	self assert: set equals: guy.
	self assert: guy firstName notNil.
	self assert: guy firstName equals: 'John'
]
