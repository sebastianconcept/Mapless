Class {
	#name : #MaplessPostgresTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Postgres-Tests-Tests'
}

{ #category : #history }
MaplessPostgresTest class >> lastStoredRun [
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

{ #category : #history }
MaplessPostgresTest class >> maplessClasses [
	^ {DummyPerson.
	DummyUser.
	DummyTag}
]

{ #category : #actions }
MaplessPostgresTest >> resetDatabase [
	"Remove all objects so the database is clean for any test to be run."

	self class maplessClasses
		do: [ :each | 
			(repository hasTableFor: each)
				ifTrue: [ repository destroyAll: each ]
				ifFalse: [ repository ensureTableFor: each ] ]
]

{ #category : #'setUp-tearDown' }
MaplessPostgresTest >> setUp [
	super setUp.
	repository := MaplessPostgresRepository
		for: 'Mapless-Tests'
		with: MaplessStandalonePostgresPool local.
	repository ensureDatabase.
	self resetDatabase
]

{ #category : #'setUp-tearDown' }
MaplessPostgresTest >> tearDown [
	super tearDown.
	repository ifNotNil: [ repository shutDown ].
	repository := nil
]

{ #category : #tests }
MaplessPostgresTest >> testComposedAccess [
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
			self
				do: [ guy save.
					user save ].
			self
				do: [ self
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
						equals: 'q' ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testComposedDelete [
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
MaplessPostgresTest >> testComposedDestroy [
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
			self do: [ users do: [ :user | user person save ] ].
			self do: [ users do: [ :user | user save ] ].
			self do: [ users do: [ :user | user person destroy ] ].
			self
				do: [ self
						assert:
							(users
								allSatisfy: [ :user | (DummyPerson existsId: user person id) not ]).
					self
						assert: (users allSatisfy: [ :user | DummyUser existsId: user id ]) ].
			self do: [ users do: [ :user | user destroy ] ].
			self
				assert:
					(self
						do: [ users allSatisfy: [ :user | (DummyUser existsId: user id) not ] ]) ]
]

{ #category : #tests }
MaplessPostgresTest >> testComposedSave [
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
			self
				should: [ self do: [ user save ] ]
				raise: MaplessUnsavedSubmodel.

			"After saving that submodel"
			self do: [ guy save ].
			self
				shouldnt: [ self do: [ user save ] ]
				raise: MaplessUnsavedSubmodel ]
]

{ #category : #tests }
MaplessPostgresTest >> testComposedSaveAndLoad [
	| user guy loaded |
	self
		do: [ user := DummyUser new
				username: 'johnq';
				yourself.
			guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			user person: guy.

			"Whithout saving a submodel"
			self
				should: [ self do: [ user save ] ]
				raise: MaplessUnsavedSubmodel.

			"After saving that submodel"
			self do: [ guy save ].
			self
				shouldnt: [ self do: [ user save ] ]
				raise: MaplessUnsavedSubmodel.
			self
				do: [ loaded := DummyUser findId: user id.
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
						keysAndValuesDo: [ :k :v | self assert: v = (user data at: k) ].
					self assert: loaded username = 'johnq'.
					self assert: loaded person firstName = 'john'.
					self assert: loaded person lastName = 'q'.
					self assert: loaded person modelClass = DummyPerson asString.
					self assert: loaded person model class = DummyPerson ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testComposition [
	| user guy |
	user := DummyUser new
		userame: 'johnq';
		yourself.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user person: guy.
	self
		assert: (user maplessData at: 'person') class
		equals: DummyPerson.
	self assert: user id isNil.
	self assert: (user maplessData at: 'person') id isNil.
	self assert: user completeName equals: 'john q'
]

{ #category : #tests }
MaplessPostgresTest >> testDateAndTime [
	| when guy loaded |
	when := DateAndTime now.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		createdOn: when;
		yourself.
	self
		do: [ guy save.
			loaded := DummyPerson findId: guy id.
			self
				assert: loaded createdOn asDate asString = when asDate asString.
			self assert: loaded createdOn asLocal = when asLocal.
			self assert: loaded createdOn asTime minutes = when asTime minutes.
			self assert: loaded createdOn asTime seconds = when asTime seconds ]
]

{ #category : #tests }
MaplessPostgresTest >> testDelete [
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
MaplessPostgresTest >> testDestroy [
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
MaplessPostgresTest >> testIsUnsaved [
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
MaplessPostgresTest >> testMultipleComposedComposables [
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
			self do: [ tagsOfTagsOfTags do: [ :tag | tag save ] ].
			tagsOfTags first tags: tagsOfTagsOfTags.
			tagsOfTags second tags: tagsOfTagsOfTags.
			self
				shouldnt: [ self do: [ tagsOfTags do: [ :tag | tag save ] ] ]
				raise: MaplessUnsavedSubmodel.
			tags first tags: tagsOfTags.
			tags second tags: tagsOfTags.
			tags third tags: tagsOfTags.
			self
				shouldnt: [ self do: [ tags do: [ :e | e save ] ] ]
				raise: MaplessUnsavedSubmodel.
			self
				do: [ loaded := DummyTag findId: tags first id.
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
					self assert: loaded tags first tags second label = 'nice' ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testMultipleComposedMixedSaveAndLoad [
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
			self do: [ guy things do: [ :each | each save ] ].
			self
				shouldnt: [ self do: [ guy save ] ]
				raise: MaplessUnsavedSubmodel.
			self
				do: [ loaded := DummyPerson findId: guy id.
					self assert: loaded notNil.
					self assert: loaded firstName = 'john'.
					self assert: loaded things isCollection.
					self assert: loaded things notEmpty.
					loaded things
						do: [ :each | self assert: (things anySatisfy: [ :t | t id = each id ]) ].
					loaded unreferenced.
					self assert: loaded things first class = DummyTag.
					self assert: loaded things second class = DummyTag.
					self assert: loaded things third class = DummyUser ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testMultipleComposedSaveAndLoad [
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
			self do: [ tags do: [ :tag | tag save ] ].
			self do: [ guy save ].
			self
				shouldnt: [ self do: [ user save ] ]
				raise: MaplessUnsavedSubmodel.
			self
				do: [ loaded := DummyUser findId: user id.
					self assert: loaded notNil.
					self assert: loaded username = 'johnq'.
					self assert: loaded tags isCollection.
					self assert: loaded tags notEmpty.
					self assert: loaded tags isCollection.
					loaded tags
						do: [ :tag | self assert: (tags anySatisfy: [ :t | t id = tag id ]) ] ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testQueryUsers [
	| users |
	users := OrderedCollection new.
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
						allSatisfy:
							[ :char | (DummyUser find: 'username = ''' , char asString , '''') notNil ]) ]
]

{ #category : #tests }
MaplessPostgresTest >> testSaveSetsID [
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
MaplessPostgresTest >> testSimpleSave [
	| guy |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self shouldnt: [ repository save: guy ] raise: Error
]

{ #category : #tests }
MaplessPostgresTest >> testSimpleSaveAndLoad [
	| guy loaded |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	loaded := repository findOne: DummyPerson atId: guy id.
	self assert: loaded notNil.
	loaded modifiedOn: nil.
	guy modifiedOn: nil.
	loaded maplessData
		keysAndValuesDo: [ :k :v | 
			((loaded data at: k) isKindOf: DateAndTime) not
				ifTrue: [ self assert: (loaded data at: k) = (guy data at: k) ] ]
]

{ #category : #tests }
MaplessPostgresTest >> testSimpleSaveAndUpdate [
	| guy loaded reloaded |
	self
		do: [ guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			self do: [ guy save ].
			self do: [ loaded := DummyPerson findId: guy id ].
			self assert: loaded firstName = 'john'.
			self deny: loaded remember = 'this words'.
			loaded remember: 'this words'.
			self do: [ loaded save ].
			self do: [ reloaded := DummyPerson findId: guy id ].
			self assert: reloaded remember = 'this words' ]
]

{ #category : #tests }
MaplessPostgresTest >> testSubModelsFromReifiedJSON [
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
			reified := DummyUser fromJSONString: jsonString.
			self assert: reified person class equals: DummyPerson.
			self assert: reified completeName equals: 'john q' ]
]
