Class {
	#name : #MaplessWithoutDynamicVariableTest,
	#superclass : #MaplessMongoMultiRepositoryTest,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #running }
MaplessWithoutDynamicVariableTest >> testSaveToAndReadFromTwoDatabases [
	| repo1 repo2 guy found |
	repo1 := MaplessMongoRepository
		for: 'Mapless-Test1'
		with: MaplessMongoPool local.
	repo2 := MaplessMongoRepository
		for: 'Mapless-Test2'
		with: MaplessMongoPool local.
	repositories at: 1 put: repo1.
	repositories at: 2 put: repo2.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self deny: guy hasId.
	repo1 save: guy.
	self assert: guy hasId.
	found := repo1 findOne: DummyPerson atId: guy id.
	self assert: found notNil.
	self assert: found firstName equals: guy firstName.
	guy := DummyPerson new
		firstName: 'peter';
		lastName: 'e';
		yourself.
	self deny: guy hasId.
	repo2 save: guy.
	self assert: guy hasId.
	found := repo2 findOne: DummyPerson atId: guy id.
	self assert: found notNil.
	self assert: found firstName equals: guy firstName
]

{ #category : #running }
MaplessWithoutDynamicVariableTest >> testUseSubmapless [
	| repo user guy found |
	repo := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessMongoPool local.
	repositories at: 1 put: repo.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	user := DummyUser new
		uername: 'e';
		person: guy;
		yourself.
	repo save: guy.
	repo save: user.
	found := repo findOne: DummyUser atId: user id.
	self assert: found notNil.
	self assert: found person firstName equals: guy firstName.
	self assert: found completeName equals: 'john q'
]
