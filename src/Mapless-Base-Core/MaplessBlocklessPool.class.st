"
I'm a thread-safe pool that doesn't block.
See WaitfreeQueue for details.
"
Class {
	#name : #MaplessBlocklessPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'clients',
		'minimum',
		'maximum'
	],
	#category : #'Mapless-Base-Core-Repositories'
}

{ #category : #accessing }
MaplessBlocklessPool >> clients [
	^ clients
]

{ #category : #actions }
MaplessBlocklessPool >> closeClient: aClient [
	self subclassResponsibility
]

{ #category : #actions }
MaplessBlocklessPool >> ensureClients [
	[ minimum > clients size ]
		whileTrue: [ clients nextPut: self makeClient ]
]

{ #category : #initialization }
MaplessBlocklessPool >> initialize [
	super initialize.
	minimum := self class defaultMinimum.
	maximum := self class defaultMaximum.
	clients := WaitfreeQueue new
]

{ #category : #testing }
MaplessBlocklessPool >> isClientConnected: aClient [
	"Answers true if the resource is actually active."

	self subclassResponsibility
]

{ #category : #actions }
MaplessBlocklessPool >> makeClient [
	self subclassResponsibility
]

{ #category : #accessing }
MaplessBlocklessPool >> maximum [
	^ maximum
]

{ #category : #accessing }
MaplessBlocklessPool >> maximum: anObject [
	maximum := anObject
]

{ #category : #accessing }
MaplessBlocklessPool >> minimum [
	^ minimum
]

{ #category : #accessing }
MaplessBlocklessPool >> minimum: anObject [
	minimum := anObject
]

{ #category : #actions }
MaplessBlocklessPool >> onError: exception client: client [
	"no-op"
]

{ #category : #actions }
MaplessBlocklessPool >> requestClient [
	| client |
	self ensureClients.
	client := clients nextOrNil ifNil: [ self makeClient ].
	^ client
]

{ #category : #actions }
MaplessBlocklessPool >> resetClients [
	| client |
	[ clients isEmpty ]
		whileFalse: [ client := clients nextOrNil.
			client
				ifNotNil: [ (self isClientConnected: client)
						ifTrue: [ self closeClient: client ] ] ]
]

{ #category : #actions }
MaplessBlocklessPool >> returnClient: client [
	clients size < self maximum
		ifTrue: [ clients nextPut: client ]
		ifFalse: [ (self isClientConnected: client)
				ifTrue: [ self closeClient: client ] ]
]

{ #category : #actions }
MaplessBlocklessPool >> start [
	self resetClients.
	self ensureClients
]

{ #category : #actions }
MaplessBlocklessPool >> stop [
	self resetClients
]

{ #category : #actions }
MaplessBlocklessPool >> withClientDo: aBlock [
	| client |
	client := self requestClient.
	^ self currentClientDynamicVariable
		value: client
		during: [ [ [ aBlock value: client ]
				on: Error
				do: [ :x | 
					self onError: x client: client.
					x pass ] ]
				ensure: [ self returnClient: client ] ]
]
