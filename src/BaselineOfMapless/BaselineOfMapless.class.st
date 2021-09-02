Class {
	#name : #BaselineOfMapless,
	#superclass : #BaselineOf,
	#category : #BaselineOfMapless
}

{ #category : #baseline }
BaselineOfMapless >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self setUpDependencies: spec.
			self setUpPackages: spec.
			spec
				group: 'Core' with: #('Mapless-Base-Core');
				group: 'Memory' with: #('Mapless-Memory-Tests');
				group: 'Mongo' with: #('Mapless-Mongo-Tests');
				group: 'Postgres' with: #('Mapless-Postgres-Tests');
				group: 'Benchmark' with: #('Mapless-Benchmark-Core');
				group: 'default' with: #('Mongo') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpDependencies: spec [
	spec
		baseline: 'JSONExtensions'
		with: [ spec repository: 'github://sebastianconcept/JSONExtensions/src' ].
	spec
		baseline: 'MongoTalk'
		with: [ spec repository: 'github://pharo-nosql/mongotalk:1.25/mc' ].
	spec baseline: 'P3' with: [ spec repository: 'github://svenvc/P3' ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpPackages: spec [
	spec
		package: 'Mapless-Base-Core'
		with: [ spec requires: 'JSONExtensions' ].
	spec
		package: 'Mapless-Tests-Base'
		with: [ spec requires: 'Mapless-Base-Core' ].
	spec
		package: 'Mapless-Memory-Core'
		with: [ spec requires: #('Mapless-Base-Core') ].
	spec
		package: 'Mapless-Memory-Tests'
		with: [ spec requires: #('Mapless-Memory-Core') ].
	spec
		package: 'Mapless-Mongo-Core'
		with: [ spec requires: #('Mapless-Base-Core' 'MongoTalk') ].
	spec
		package: 'Mapless-Mongo-Tests'
		with: [ spec requires: #('Mapless-Mongo-Core' 'Mapless-Tests-Base') ].
	spec
		package: 'Mapless-Benchmark-Core'
		with: [ spec requires: 'Mapless-Mongo-Tests' ].
	spec
		package: 'Mapless-Postgres-Core'
		with: [ spec requires: #('Mapless-Base-Core' 'P3') ].
	spec
		package: 'Mapless-Postgres-Tests'
		with: [ spec requires: #('Mapless-Postgres-Core' 'Mapless-Tests-Base') ]
]
