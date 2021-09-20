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

{ #category : #tests }
MaplessMongoTest >> newDummyPersonNamed: aString [
	^ DummyPerson new
		firstName: aString;
		yourself
]

{ #category : #'setUp-tearDown' }
MaplessMongoTest >> setUp [
	super setUp.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessMongoPool local
]

{ #category : #'setUp-tearDown' }
MaplessMongoTest >> tearDown [
	super tearDown.
	repository
		drop;
		shutDown
]

{ #category : #tests }
MaplessMongoTest >> testComposedAccess [
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	self
		do: [ user := DummyUser new
				userame: 'johnq';
				yourself.
			guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.
			guy save.
			user save.
			self
				assert: (DummyUser findId: user id) completeName
				equals: 'john q'.
			self
				assert: (DummyUser findId: user id) person class
				equals: MaplessReference.
			self
				assert: (DummyUser findId: user id) person model class
				equals: DummyPerson.
			self
				assert: (DummyUser findId: user id) person firstName
				equals: 'john'.
			self
				assert: (DummyUser findId: user id) person lastName
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
							(DummyUser new
								userame: char asString;
								person:
									(DummyPerson new
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
							(DummyUser new
								userame: char asString;
								person:
									(DummyPerson new
										firstName: char asString;
										yourself);
								yourself) ].
			users do: [ :user | user person save ].
			users do: [ :user | user save ].
			users do: [ :user | user person destroy ].
			self
				assert:
					(users
						allSatisfy: [ :user | (DummyPerson existsId: user person id) not ]).
			self
				assert: (users allSatisfy: [ :user | DummyUser existsId: user id ]).
			users do: [ :user | user destroy ].
			self
				assert: (users allSatisfy: [ :user | (DummyUser existsId: user id) not ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedResaveAndLoad [
	| user guy loaded |
	self
		do: [ user := DummyUser new
				username: 'johnq';
				yourself.
			guy := DummyPerson new
				firstName: 'John';
				lastName: 'W';
				yourself.
			user person: guy.
			guy save.
			self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel.
			loaded := DummyUser findId: user id.
			self assert: loaded person firstName equals: 'John'.
			loaded person lastName: 'wayne'.
			loaded person save.
			loaded := DummyUser findId: user id.
			self assert: loaded person lastName equals: 'wayne'.
			loaded := DummyUser findId: user id.
			self assert: loaded person firstName equals: 'John'.
			loaded person lastName: 'Wayne'.
			loaded person save.
			loaded username: 'johnw'.
			loaded save.
			loaded := DummyUser findId: user id.
			self assert: loaded username equals: 'johnw'.
			self assert: loaded person firstName equals: 'John' ]
]

{ #category : #tests }
MaplessMongoTest >> testComposedSave [
	| user guy |
	self
		do: [ user := DummyUser new
				userame: 'johnq';
				yourself.
			guy := DummyPerson new
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
	self
		do: [ user := DummyUser new
				createdOn: DateAndTime now;
				username: 'johnq';
				yourself.
			guy := DummyPerson new
				createdOn: DateAndTime now;
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.

			"Whithout saving a submodel"
			self should: [ user save ] raise: MaplessUnsavedSubmodel.

			"After saving that submodel"
			guy save.
			self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel.
			loaded := DummyUser findId: user id.
			self assert: loaded notNil.
			self assert: loaded createdOn notNil.
			self assert: loaded modifiedOn notNil.
			loaded
				createdOn: nil;
				modifiedOn: nil.
			user
				createdOn: nil;
				modifiedOn: nil.
			loaded data
				keysAndValuesDo: [ :k :v | self assert: v equals: (user data at: k) ].
			self assert: loaded username = 'johnq'.
			self assert: loaded person firstName = 'john'.
			self assert: loaded person lastName = 'q'.
			self assert: loaded person maplessClassName = DummyPerson name.
			self assert: loaded person model class = DummyPerson ]
]

{ #category : #tests }
MaplessMongoTest >> testComposition [
	| user guy |
	self
		do: [ user := DummyUser new
				userame: 'johnq';
				yourself.
			guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.
			self assert: (user data at: 'person') class equals: DummyPerson.
			self assert: (user data at: 'person') _c equals: #DummyPerson.
			self assert: user id isNil.
			self assert: (user data at: 'person') id isNil.
			self assert: user completeName equals: 'john q' ]
]

{ #category : #tests }
MaplessMongoTest >> testDateAndTime [
	| when guy loaded |
	self
		do: [ when := DateAndTime now asUTC.
			guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				createdOn: when;
				yourself.
			guy save.
			loaded := DummyPerson findId: guy id.
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
							(DummyPerson new
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
							(DummyPerson new
								firstName: char asString;
								yourself) ].
			people do: [ :guy | guy save ].
			self assert: (people allSatisfy: [ :guy | guy isDeleted not ]).
			people do: [ :guy | guy destroy ].
			self
				assert: (people allSatisfy: [ :guy | (DummyPerson existsId: guy id) not ]) ]
]

{ #category : #tests }
MaplessMongoTest >> testFindAll [
	| found |
	repository
		do: [ (self newDummyPersonNamed: 'Peter') save.
			(self newDummyPersonNamed: 'Robert') save.
			(self newDummyPersonNamed: 'John') save.
			found := DummyPerson findAll.
			self assert: found notNil.
			self assert: found size equals: 3 ]
]

{ #category : #tests }
MaplessMongoTest >> testFindAllSorted [
	| found |
	repository
		do: [ (self newDummyPersonNamed: 'Peter') save.
			(self newDummyPersonNamed: 'Robert') save.
			(self newDummyPersonNamed: 'John') save.
			found := DummyPerson findAllSort: {(#firstName -> 1)} asDictionary.
			self assert: found notNil.
			self assert: found size equals: 3.
			self assert: found notNil.
			self assert: found first firstName = 'John'.
			self assert: found last firstName = 'Robert' ]
]

{ #category : #tests }
MaplessMongoTest >> testIsUnsaved [
	| guy |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self do: [ guy save ]
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
					(DummyTag new
						label: 'is this';
						yourself);
				add:
					(DummyTag new
						label: 'multiply';
						yourself);
				add:
					(DummyTag new
						label: 'composable?';
						yourself);
				yourself.
			tagsOfTags
				add:
					(DummyTag new
						label: 'like';
						yourself);
				add:
					(DummyTag new
						label: 'really?';
						yourself);
				yourself.
			tagsOfTagsOfTags
				add:
					(DummyTag new
						label: 'wow';
						yourself);
				add:
					(DummyTag new
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
			loaded := DummyTag findId: tags first id.
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
	self
		do: [ guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			guy things: OrderedCollection new.
			guy things
				add:
					(DummyTag new
						label: 'cool';
						yourself);
				add:
					(DummyTag new
						label: 'stuff';
						yourself);
				add:
					(DummyUser new
						info: 'also this';
						yourself);
				yourself.
			things := guy things.
			guy things do: [ :each | each save ].
			self
				shouldnt: [ self do: [ guy save ] ]
				raise: MaplessUnsavedSubmodel.
			loaded := DummyPerson findId: guy id.
			self assert: loaded notNil.
			self assert: loaded firstName = 'john'.
			self assert: loaded things isCollection.
			self assert: loaded things notEmpty.
			loaded things
				do: [ :each | self assert: (things anySatisfy: [ :t | t id = each id ]) ].
			loaded unreferenced.
			self assert: loaded things first class = DummyTag.
			self assert: loaded things second class = DummyTag.
			self assert: loaded things third class = DummyUser ]
]

{ #category : #tests }
MaplessMongoTest >> testMultipleComposedSaveAndLoad [
	| user guy tags loaded |
	self
		do: [ user := DummyUser new
				username: 'johnq';
				yourself.
			guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			tags := OrderedCollection new.
			tags
				add:
					(DummyTag new
						label: 'cool';
						yourself);
				add:
					(DummyTag new
						label: 'stuff';
						yourself);
				yourself.
			user
				person: guy;
				tags: tags;
				yourself.
			tags do: [ :tag | tag save ].
			guy save.
			self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel.
			loaded := DummyUser findId: user id.
			self assert: loaded notNil.
			self assert: loaded username = 'johnq'.
			self assert: loaded tags isCollection.
			self assert: loaded tags notEmpty.
			self assert: loaded tags isCollection.
			loaded tags
				do: [ :tag | self assert: (tags anySatisfy: [ :t | t id = tag id ]) ] ]
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
							(DummyUser new
								username: char asString;
								person:
									(DummyPerson new
										firstName: char asString;
										yourself);
								yourself) ].
			self do: [ users do: [ :user | user person save ] ].
			self do: [ users do: [ :user | user save ] ].
			self
				do: [ self
						assert:
							(Character alphabet
								allSatisfy: [ :char | (DummyUser findUsername: char asString) notNil ]) ] ]
]

{ #category : #tests }
MaplessMongoTest >> testSaveSetsID [
	| guy |
	guy := DummyPerson new
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
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self do: [ guy save ]
]

{ #category : #tests }
MaplessMongoTest >> testSimpleSaveAndLoad [
	| guy loaded |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self
		do: [ guy save.
			loaded := DummyPerson findId: guy id ].
	self assert: loaded notNil.
	loaded data
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessMongoTest >> testSimpleSaveAndUpdate [
	| guy loaded reloaded |
	self
		do: [ guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			self
				do: [ guy save.
					loaded := DummyPerson findId: guy id ].
			self assert: loaded firstName equals: 'john'.
			self deny: loaded remember equals: 'this words'.
			loaded remember: 'this words'.
			self
				do: [ loaded save.
					reloaded := DummyPerson findId: guy id ].
			self assert: reloaded remember = 'this words' ]
]

{ #category : #tests }
MaplessMongoTest >> testSubModelsFromReifiedJSON [
	| user guy jsonString reified |
	self
		do: [ user := DummyUser new
				userame: 'johnq';
				yourself.
			guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.
			jsonString := user unreferenced asJSONString.
			reified := DummyUser
				fromJSONString: jsonString
				in: self currentRepository.
			self assert: reified person class equals: DummyPerson.
			self assert: reified completeName equals: 'john q' ]
]
