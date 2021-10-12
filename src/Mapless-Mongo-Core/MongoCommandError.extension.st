Extension { #name : #MongoCommandError }

{ #category : #'*Mapless-Mongo-Core' }
MongoCommandError class >> signalFor: aReply [
	^ ((self allSubclasses
		detect: [ :class | class code = (aReply at: 'code' ifAbsent: [ nil ]) ]
		ifNone: [ self ]) newFor: aReply) signal
]
