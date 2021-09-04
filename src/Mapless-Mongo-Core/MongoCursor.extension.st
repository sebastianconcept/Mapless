Extension { #name : #MongoCursor }

{ #category : #'*Mapless-Mongo-Core' }
MongoCursor >> execute [
	| limit reply numberReturned requestId |
	numberReturned := 0.
	limit := query limit.
	limit = 0
		ifTrue: [ limit := Float infinity ].
	limit < query chunkSize
		ifTrue: [ query chunkSize: limit ].
	reply := nil.
	[ reply isNil
		ifTrue: [ requestId := root cursorQuery: query ]
		ifFalse: [ requestId := root
				getMore: reply cursorId
				collection: query collection qualifiedName
				chunkSize: query chunkSize ].
	reply := (ReplyOperation stream: root stream) read.
	reply responseTo = requestId
		ifFalse: [ ^ MongoOperationError
				signalFor: reply
				message: 'Unexpected responseTo in response' ].
	reply
		do: [ :each | 
			numberReturned < limit
				ifTrue: [ query doBlock value: each.
					numberReturned := numberReturned + 1 ] ].
	reply isFinished or: [ numberReturned >= limit ] ] whileFalse
]
