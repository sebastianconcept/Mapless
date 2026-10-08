Extension { #name : #MongoCommandError }

{ #category : #'*Mapless-Mongo' }
MongoCommandError class >> code [
	^ nil
]

{ #category : #'*Mapless-Mongo' }
MongoCommandError class >> signalFor: aReply [
	| errorClass |
	errorClass := self allSubclasses
		detect: [ :each | each code = (aReply at: 'code' ifAbsent: [ nil ]) ]
		ifNone: [ MongoCommandError ].
	^ (errorClass newFor: aReply) signal
]
