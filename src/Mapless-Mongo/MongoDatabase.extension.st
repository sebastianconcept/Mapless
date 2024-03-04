Extension { #name : #MongoDatabase }

{ #category : #'*Mapless-Mongo' }
MongoDatabase >> commandUpdate: origDictionary with: newDictionary collection: collectionName writeConcern: aConcern [
	^ self
		commandUpdate: origDictionary
		with: newDictionary
		collection: collectionName
		writeConcern: aConcern
		upsert: false
		multi: false
]

{ #category : #'*Mapless-Mongo' }
MongoDatabase >> commandUpdate: origDictionary with: newDictionary collection: collectionName writeConcern: aConcern upsert: isUpsert multi: isMulti [
	"Update using Mongo command. Answer the output of the command.
	See more on https://docs.mongodb.com/manual/reference/command/update/"

	| dict |
	dict := {('update' -> collectionName).
	('updates'
		->
			{({('q' -> origDictionary).
			('u' -> newDictionary).
			('upsert' -> isUpsert).
			('multi' -> isMulti)} as: OrderedDictionary)})}
		as: OrderedDictionary.
	aConcern
		ifNotNil: [ dict at: 'writeConcern' put: aConcern concernForCommand ].
	^ self commandAndVerify: dict
]

{ #category : #'*Mapless-Mongo' }
MongoDatabase >> commandUpsert: origDictionary with: newDictionary collection: collectionName writeConcern: aConcern [
	^ self
		commandUpdate: origDictionary
		with: newDictionary
		collection: collectionName
		writeConcern: aConcern
		upsert: true
		multi: false
]
