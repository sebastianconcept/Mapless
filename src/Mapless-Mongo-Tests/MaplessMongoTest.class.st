Class {
	#name : #MaplessMongoTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #history }
MaplessMongoTest class >> lastStoredRun [
	^ Dictionary new
		add:
			#passed
				->
					(Set new
						add: #testDefaultCategoryCleanUp;
						add: #testPackageCleanUp;
						add: #testSingleClassCreation;
						add: #testClassCreationInDifferentCategories;
						add: #testClassFastCreationInDifferentCategories;
						add: #testMultipleClassCreation;
						add: #testSingleClassFastCreation;
						yourself);
		add: #timeStamp -> '22 November 2008 10:11:35 pm';
		add: #failures -> Set new;
		add: #errors -> Set new;
		yourself
]

{ #category : #accessing }
MaplessMongoTest >> currentRepository [
	^ MaplessCurrentRepository value
]

{ #category : #actions }
MaplessMongoTest >> do: aBlock [
	^ repository do: aBlock
]

{ #category : #actions }
MaplessMongoTest >> newRepository [
	^ MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessStandaloneMongoPool local
]

{ #category : #tests }
MaplessMongoTest >> newSamplePersonNamed: aString [
	^ SamplePerson new
		firstName: aString;
		yourself
]

{ #category : #'setUp-tearDown' }
MaplessMongoTest >> setUp [
	super setUp.
	repository := self newRepository.

]

{ #category : #'setUp-tearDown' }
MaplessMongoTest >> tearDown [
	super tearDown.
	repository
		drop;
		shutDown
]

{ #category : #tests }
MaplessMongoTest >> testAfterDestroyed [

	| guy |
	guy := SamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	self assert: guy recentlyDestroyed isNil.
	self do: [ guy save ].
	self assert: guy recentlySaved.
	self do: [ guy destroy ].
	self assert: guy recentlyDestroyed
]

{ #category : #tests }
MaplessMongoTest >> testAfterSaved [

	| guy |
	guy := SamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	self assert: guy recentlySaved isNil.
	self do: [ guy save ].
	self assert: guy recentlySaved
]

{ #category : #tests }
MaplessMongoTest >> testComposedAccess [
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	repository
		readWriteDo: [ user := SampleUser new
				userame: 'johnq';
				yourself.
			guy := SamplePerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.
			guy save.
			user save ].
	repository
		readOnlyDo: [ 
			self waitABit.
			self
				assert: (SampleUser findId: user id) completeName
				equals: 'john q'.
			self
				assert: (SampleUser findId: user id) person class
				equals: MaplessReference.
			self
				assert: (SampleUser findId: user id) person model class
				equals: SamplePerson.
			self
				assert: (SampleUser findId: user id) person firstName
				equals: 'john'.
			self
				assert: (SampleUser findId: user id) person lastName
				equals: 'q' ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedDelete [
	| users |
	users := OrderedCollection new.
	self
		do: [ Character alphabet
				do: [ :char | 
					users
						add:
							(SampleUser new
								userame: char asString;
								person:
									(SamplePerson new
										firstName: char asString;
										yourself);
								yourself) ].
			self do: [ users do: [ :user | user person save ] ].
			self do: [ users do: [ :user | user save ] ].
			self assert: (users allSatisfy: [ :user | user isDeleted not ]).
			self
				assert: (users allSatisfy: [ :user | user person isDeleted not ]).
			self do: [ users do: [ :user | user person delete ] ].
			self assert: (users allSatisfy: [ :user | user person isDeleted ]).
			self assert: (users allSatisfy: [ :user | user isDeleted not ]).
			self do: [ users do: [ :user | user delete ] ].
			self assert: (users allSatisfy: [ :user | user person isDeleted ]).
			self assert: (users allSatisfy: [ :user | user isDeleted ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedDestroy [
	| users |
	self
		do: [ users := OrderedCollection new.
			Character alphabet
				do: [ :char | 
					users
						add:
							(SampleUser new
								userame: char asString;
								person:
									(SamplePerson new
										firstName: char asString;
										yourself);
								yourself) ].
			users do: [ :user | user person save ].
			users do: [ :user | user save ].
			users do: [ :user | user person destroy ].
			self
				assert:
					(users
						allSatisfy: [ :user | (SamplePerson existsId: user person id) not ]).
			self
				assert: (users allSatisfy: [ :user | SampleUser existsId: user id ]).
			users do: [ :user | user destroy ].
			self
				assert: (users allSatisfy: [ :user | (SampleUser existsId: user id) not ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedResaveAndLoad [
	| user guy loaded |
	repository
		readWriteDo: [ user := SampleUser new
				username: 'johnq';
				yourself.
			guy := SamplePerson new
				firstName: 'John';
				lastName: 'W';
				yourself.
			user person: guy.
			guy save.
			self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel ].
	repository
		readOnlyDo: [ 
			self waitABit.
			loaded := SampleUser findId: user id.
			self assert: loaded person firstName equals: 'John'.
			loaded person lastName: 'wayne'.
			loaded person save.
			loaded := SampleUser findId: user id.
			self assert: loaded person lastName equals: 'wayne'.
			loaded := SampleUser findId: user id.
			self assert: loaded person firstName equals: 'John' ].
	repository
		readWriteDo: [ loaded person lastName: 'Wayne'.
			loaded person save.
			loaded username: 'johnw'.
			loaded save ].
	repository
		readOnlyDo: [ loaded := SampleUser findId: user id.
			self assert: loaded username equals: 'johnw'.
			self assert: loaded person firstName equals: 'John' ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedSave [
	| user guy |
	self
		do: [ user := SampleUser new
				userame: 'johnq';
				yourself.
			guy := SamplePerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.

			"Whithout saving a submodel"
			self should: [ user save ] raise: MaplessUnsavedSubmodel.

			"After saving that submodel"
			guy save.
			self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedSaveAndLoad [
	| user guy loaded |
	repository
		readWriteDo: [ user := SampleUser new
				createdOn: DateAndTime now;
				username: 'johnq';
				yourself.
			guy := SamplePerson new
				createdOn: DateAndTime now;
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.

			"Whithout saving a submodel"
			self should: [ user save ] raise: MaplessUnsavedSubmodel ]
]

{ #category : #tests }
MaplessMongoTest >> testComposition [
	| user guy |
	self
		do: [ user := SampleUser new
				userame: 'johnq';
				yourself.
			guy := SamplePerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.
			self assert: (user data at: 'person') class equals: SamplePerson.
			self assert: (user data at: 'person') _c equals: #SamplePerson.
			self assert: user id isNil.
			self assert: (user data at: 'person') id isNil.
			self assert: user completeName equals: 'john q' ]
]

{ #category : #tests }
MaplessMongoTest >> testDateAndTime [
	| when guy loaded |
	when := DateAndTime now asUTC.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		createdOn: when;
		yourself.
	repository save: guy.
	repository
		readOnlyDo: [ self waitABit.
			loaded := repository findOne: SamplePerson atId: guy id.
			self
				assert: loaded createdOn asDate asString = when asDate asString.
			self assert: loaded createdOn asTime hour = when asTime hour.
			self assert: loaded createdOn asTime minutes = when asTime minutes.
			self assert: loaded createdOn asTime seconds = when asTime seconds ]
]

{ #category : #tests }
MaplessMongoTest >> testDelete [
	| people |
	self
		do: [ people := OrderedCollection new.
			Character alphabet
				do: [ :char | 
					people
						add:
							(SamplePerson new
								firstName: char asString;
								yourself) ].
			people do: [ :guy | guy save ].
			self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
			people do: [ :guy | guy delete ].
			self assert: (people allSatisfy: [ :guy | guy isDeleted ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testDestroy [
	| people |
	self
		do: [ people := OrderedCollection new.
			Character alphabet
				do: [ :char | 
					people
						add:
							(SamplePerson new
								firstName: char asString;
								yourself) ].
			people do: [ :guy | guy save ].
			self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
			people do: [ :guy | guy destroy ].
			self
				assert: (people allSatisfy: [ :guy | (SamplePerson existsId: guy id) not ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testDestroyAll [
	| people |
	self
		do: [ people := OrderedCollection new.
			Character alphabet
				do: [ :char | 
					people
						add:
							(SamplePerson new
								firstName: char asString;
								yourself) ].
			people do: [ :guy | guy save ].
			self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
			SamplePerson getRepository destroyAll: SamplePerson.

			self
				assert: (people allSatisfy: [ :guy | (SamplePerson existsId: guy id) not ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testDestroyById [

	| guy |
	self do: [
		guy := SampleUser new
			       userame: 'johnq';
			       save ].
	self do: [ self assert: (SampleUser existsId: guy id) ].
	self
		shouldnt: [ repository destroyOne: SampleUser atId: guy id ]
		raise: Error.

	self do: [ self deny: (SampleUser existsId: guy id) ]
]

{ #category : #tests }
MaplessMongoTest >> testFindAll [
	| found |
	repository
		readWriteDo: [ (self newSamplePersonNamed: 'Peter') save.
			(self newSamplePersonNamed: 'Robert') save.
			(self newSamplePersonNamed: 'John') save ].
	repository
		readOnlyDo: [ 
			self waitABit.
			found := SamplePerson findAll.
			self assert: found notNil.
			self assert: found size equals: 3 ]
]

{ #category : #tests }
MaplessMongoTest >> testFindAllSorted [
	| found |
	repository
		readWriteDo: [ (self newSamplePersonNamed: 'Peter') save.
			(self newSamplePersonNamed: 'Robert') save.
			(self newSamplePersonNamed: 'John') save ].
	repository
		readOnlyDo: [ 
			self waitABit.
			found := SamplePerson findAllSort: {(#firstName -> 1)} asDictionary.
			self assert: found notNil.
			self assert: found size equals: 3.
			self assert: found notNil.
			self assert: found first firstName = 'John'.
			self assert: found last firstName = 'Robert' ]
]

{ #category : #tests }
MaplessMongoTest >> testFirst [

	| found |
	repository readWriteDo: [ (self newSamplePersonNamed: 'Peter') save ].
	repository readOnlyDo: [
		self waitABit.
		found := SamplePerson first.
		self assert: found notNil.
		self assert: found firstName equals: 'Peter' ]
]

{ #category : #tests }
MaplessMongoTest >> testIsUnsaved [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self do: [ guy save ]
]

{ #category : #tests }
MaplessMongoTest >> testMaplessClass [

	| user guy reference |
	self do: [
		user := SampleUser new
			        userame: 'johnq';
			        yourself.
		guy := SamplePerson new
			       firstName: 'john';
			       lastName: 'q';
			       yourself.
		user person: guy.

		guy save.
		user save.
		self assert: SamplePerson maplessClass equals: SamplePerson.
		reference := SampleUser first person.
		self assert: reference class equals: MaplessReference.
		self assert: reference maplessClass equals: SamplePerson ]
]

{ #category : #tests }
MaplessMongoTest >> testMultipleComposedComposables [
	| tags tagsOfTags tagsOfTagsOfTags loaded |
	self
		do: [ tags := OrderedCollection new.
			tagsOfTags := OrderedCollection new.
			tagsOfTagsOfTags := OrderedCollection new.
			tags
				add:
					(SampleTag new
						label: 'is this';
						yourself);
				add:
					(SampleTag new
						label: 'multiply';
						yourself);
				add:
					(SampleTag new
						label: 'composable?';
						yourself);
				yourself.
			tagsOfTags
				add:
					(SampleTag new
						label: 'like';
						yourself);
				add:
					(SampleTag new
						label: 'really?';
						yourself);
				yourself.
			tagsOfTagsOfTags
				add:
					(SampleTag new
						label: 'wow';
						yourself);
				add:
					(SampleTag new
						label: 'nice';
						yourself);
				yourself.
			tagsOfTagsOfTags do: [ :tag | tag save ].
			tagsOfTags first tags: tagsOfTagsOfTags.
			tagsOfTags second tags: tagsOfTagsOfTags.
			self
				shouldnt: [ tagsOfTags do: [ :tag | tag save ] ]
				raise: MaplessUnsavedSubmodel.
			tags first tags: tagsOfTags.
			tags second tags: tagsOfTags.
			tags third tags: tagsOfTags.
			self
				shouldnt: [ self do: [ tags do: [ :e | e save ] ] ]
				raise: MaplessUnsavedSubmodel.
			loaded := SampleTag findId: tags first id.
			self assert: loaded notNil.
			self assert: loaded label = 'is this'.
			self assert: loaded tags isCollection.
			self assert: loaded tags notEmpty.
			self assert: loaded tags isCollection.
			self deny: loaded tags first tags isEmpty.
			self assert: loaded tags first label = 'like'.
			self assert: loaded tags second label = 'really?'.
			self assert: loaded tags size = 2.
			self deny: loaded tags first tags isEmpty.
			self assert: loaded tags first tags size = 2.
			self assert: loaded tags first tags first label = 'wow'.
			self assert: loaded tags first tags second label = 'nice' ]
]

{ #category : #tests }
MaplessMongoTest >> testMultipleComposedMixedSaveAndLoad [
	| guy things loaded |
	repository
		readWriteDo: [ guy := SamplePerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			guy things: OrderedCollection new.
			guy things
				add:
					(SampleTag new
						label: 'cool';
						yourself);
				add:
					(SampleTag new
						label: 'stuff';
						yourself);
				add:
					(SampleUser new
						info: 'also this';
						yourself);
				yourself.
			things := guy things.
			guy things do: [ :each | each save ].
			self
				shouldnt: [ self do: [ guy save ] ]
				raise: MaplessUnsavedSubmodel ].
	repository
		readOnlyDo: [ self waitABit.
			loaded := SamplePerson findId: guy id.
			self assert: loaded notNil.
			self assert: loaded firstName = 'john'.
			self assert: loaded things isCollection.
			self assert: loaded things notEmpty.
			loaded things
				do: [ :each | self assert: (things anySatisfy: [ :t | t id = each id ]) ].
			loaded unreferenced.
			self assert: loaded things first class = SampleTag.
			self assert: loaded things second class = SampleTag.
			self assert: loaded things third class = SampleUser ]
]

{ #category : #tests }
MaplessMongoTest >> testMultipleComposedSaveAndLoad [
	| user guy tags loaded |
	repository
		readWriteDo: [ user := SampleUser new
				username: 'johnq';
				yourself.
			guy := SamplePerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			tags := OrderedCollection new.
			tags
				add:
					(SampleTag new
						label: 'cool';
						yourself);
				add:
					(SampleTag new
						label: 'stuff';
						yourself);
				yourself.
			user
				person: guy;
				tags: tags;
				yourself.
			tags do: [ :tag | tag save ].
			guy save.
			self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel ].
	repository
		readOnlyDo: [ self waitABit.
			loaded := SampleUser findId: user id.
			self assert: loaded notNil.
			self assert: loaded username = 'johnq'.
			self assert: loaded tags isCollection.
			self assert: loaded tags notEmpty.
			self assert: loaded tags isCollection.
			loaded tags
				do: [ :tag | self assert: (tags anySatisfy: [ :t | t id = tag id ]) ] ]
]

{ #category : #tests }
MaplessMongoTest >> testQueryConditionally [

	| users found |
	self do: [
		users := OrderedCollection new.
		Character alphabet do: [ :char |
			SampleUser new
				username: char asString;
				person: (SamplePerson new
						 firstName: char asString;
						 save);
				save ] ].

	self do: [
		found := SampleUser
			         find: { ('username' -> 'j') } asDictionary
			         limit: 1 ].
	self assert: found notNil.
	self assert: found notEmpty.
	self assert: found first username equals: 'j'
]

{ #category : #tests }
MaplessMongoTest >> testQueryConditionallySorted [

	| users found |
	self do: [
		users := OrderedCollection new.
		Character alphabet do: [ :char |
			SampleUser new
				username: char asString;
				person: (SamplePerson new
						 firstName: char asString;
						 save);
				save ] ].

	self do: [
		found := SampleUser
			         find: { ('$or' -> {
					          { (#username -> 'j') } asDictionary.
					          { (#username -> 'z') } asDictionary }) } asDictionary
			         sort: { (#username -> 1) } asDictionary ].
	self assert: found notNil.
	self assert: found notEmpty.
	self assert: found size equals: 2.
	self assert: found first username equals: 'j'.
	self assert: found second username equals: 'z'
]

{ #category : #tests }
MaplessMongoTest >> testQueryUsers [
	| users |
	self
		do: [ users := OrderedCollection new.
			Character alphabet
				do: [ :char | 
					users
						add:
							(SampleUser new
								username: char asString;
								person:
									(SamplePerson new
										firstName: char asString;
										yourself);
								yourself) ].
			self do: [ users do: [ :user | user person save ] ].
			self do: [ users do: [ :user | user save ] ].
			self
				do: [ self
						assert:
							(Character alphabet
								allSatisfy: [ :char | (SampleUser findUsername: char asString) notNil ]) ] ]
]

{ #category : #tests }
MaplessMongoTest >> testSaveSetsID [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self
		do: [ self deny: guy hasId.
			guy save.
			self assert: guy hasId ]
]

{ #category : #tests }
MaplessMongoTest >> testSimpleSave [

	| guy |
	guy := SamplePerson new
		       firstName: 'john';
		       lastName: 'q';
		       yourself.
	self do: [ guy save ].

	self assert: guy isMapless.
	self assert: guy recentlySaved
]

{ #category : #tests }
MaplessMongoTest >> testSimpleSaveAndLoad [
	| guy loaded |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository readWriteDo: [ guy save ].
	repository
		readOnlyDo: [ self waitABit.
			loaded := SamplePerson findId: guy id ].
	self assert: loaded notNil.
	loaded data
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessMongoTest >> testSimpleSaveAndUpdate [
	| guy loaded reloaded |
	repository
		readWriteDo: [ guy := SamplePerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			guy save ].
	repository
		readOnlyDo: [ self waitABit.
			loaded := SamplePerson findId: guy id.
			self assert: loaded firstName equals: 'john'.
			self deny: loaded remember equals: 'this words' ].
	loaded remember: 'this words'.
	repository
		readWriteDo: [
			loaded save.
			reloaded := repository findOne: SamplePerson atId: guy id.
			self assert: reloaded remember = 'this words' ]
]

{ #category : #tests }
MaplessMongoTest >> testSimpleSaveWithAByteSymbol [
	| guy |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		value: #thisByteSymbol;
		yourself.
	self do: [ self shouldnt: [ guy save ] raise: Error ]
]

{ #category : #tests }
MaplessMongoTest >> testSubModelsFromReifiedJSON [
	| user guy jsonString reified |
	user := SampleUser new
		userame: 'johnq';
		yourself.
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	self
		do: [ jsonString := user unreferenced asJSONString.
			reified := SampleUser fromJSONString: jsonString ].
	self assert: reified person class equals: SamplePerson.
	self assert: reified completeName equals: 'john q'
]

{ #category : #tests }
MaplessMongoTest >> testUpsert [
	| guy theId found freshFound |
	guy := SamplePerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository
		readWriteDo: [ guy upsert.
			theId := guy id ].
	repository
		readOnlyDo: [ self waitABit.
			found := SamplePerson findId: theId.
			self assert: found notNil equals: true.
			self assert: found firstName equals: 'john'.
			found firstName: 'John'.
			found upsert ].
	repository
		readOnlyDo: [ freshFound := SamplePerson findId: theId.
			self assert: freshFound firstName equals: 'John' ]
]

{ #category : #tests }
MaplessMongoTest >> testWithClientDo [

	self
		shouldnt: [
			repository withClientDo: [ :client |
				SampleUser new
					userame: 'johnq';
					save ] ]
		raise: Error
]

{ #category : #tests }
MaplessMongoTest >> testWithReadOnlyClientDo [

	self
		shouldnt: [
			repository withReadOnlyClientDo: [ :client |
				SampleUser new
					userame: 'johnq';
					save ] ]
		raise: Error
]

{ #category : #tests }
MaplessMongoTest >> testWithReadWriteClientDo [

	self
		shouldnt: [
			repository withReadWriteClientDo: [ :client |
				SampleUser new
					userame: 'johnq';
					save ] ]
		raise: Error
]

{ #category : #actions }
MaplessMongoTest >> waitABit [
	10 milliSeconds asDelay wait
]
