Class {
	#name : #MaplessTestCase,
	#superclass : #TestCase,
	#category : #'Mapless-Tests-Tests'
}

{ #category : #tests }
MaplessTestCase >> testAbstract [

	self assert: Mapless isAbstract.
	self deny: SamplePerson isAbstract
]

{ #category : #tests }
MaplessTestCase >> testDeprecated [

	self deny: SamplePerson isDeprecated
]

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
MaplessTestCase >> testMaplessClass [

	self assert: Mapless maplessClass equals: Mapless.
	self assert: SamplePerson maplessClass equals: SamplePerson
]

{ #category : #tests }
MaplessTestCase >> testMaplessErrorDefaultAction [

	self
		should: [ MaplessError signal: 'mmmmmmmmm...' ]
		raise: MaplessError.

	self should: [ MaplessError new defaultAction ] raise: UnhandledError
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
	self assert: pool port equals: 2.

	self shouldnt: [ pool logNewClient: 42 ] raise: Error.

	self deny: pool hasHealthChecker
]

{ #category : #tests }
MaplessTestCase >> testSanitizeProperties [

	| guy |
	guy := SamplePerson new.
	self assert: guy firstName isNil.
	guy
		firstName: 'John';
		lastName: 'Carpenter';
		phone: '1234'.

	self assert: guy firstName notNil.
	self assert: guy firstName equals: 'John'.
	self deny: guy phone isNil.
	guy sanitize: { #phone }.
	self deny: guy phone notNil.
	self assert: guy firstName equals: 'John'.
	
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
