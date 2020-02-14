accessing
fromResults: someMongoTalkResults

	^(someMongoTalkResults isNil or: [ someMongoTalkResults isEmpty ] )
		ifTrue: [ #() ]
		ifFalse: [ (self fromJSONObjects: someMongoTalkResults) collect: [ :each | self currentRepository onAfterRead: each ] ]