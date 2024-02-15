"
I can load the Mapless project with the default or optional modules pulling the right dependencies.

For Memory, Mongo and Redis backends you can load its default: 

Metacello new
	baseline: 'Mapless';
	repository: 'github://sebastianconcept/Mapless:master/src';
	load.
	
Or if you want, for example Memory and Postgres:

Metacello new
	baseline: 'Mapless';
	repository: 'github://sebastianconcept/Mapless:master/src';
	load: #('Memory' 'Postgres')

"
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
		do: [ self setUpBaseDependencies: spec.
			self setUpPackages: spec.
			spec
				group: 'Core' with: #('Mapless-Base-Core');
				group: 'Memory' with: #('Mapless-Memory-Tests');
				group: 'Mongo' with: #('Mapless-Mongo-Tests');
				group: 'Redis' with: #('Mapless-Redis-Tests');
				group: 'Postgres' with: #('Mapless-Postgres-Tests');
				group: 'SQLite' with: #('Mapless-SQLite-Tests');
				group: 'UnQLite' with: #('Mapless-UnQLite-Tests');
				group: 'Benchmark' with: #('Mapless-Benchmark-Core');
				group: 'default' with: #('Memory' 'SQLite') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpBaseDependencies: spec [
	spec
		baseline: 'JSON'
		with: [ spec repository: 'github://sebastianconcept/JSON:v1.0.2/src' ].
	spec
		baseline: 'NeoJSON'
		with: [ spec repository: 'github://svenvc/NeoJSON:v18/repository' ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpBasePackages: spec [
	spec
		package: 'Mapless-Base-Core'
		with: [ spec requires: 'JSON' ].
	spec
		package: 'Mapless-Tests-Base'
		with: [ spec requires: 'Mapless-Base-Core' ].
	spec
		package: 'Mapless-Memory-Core'
		with: [ spec requires: #('Mapless-Base-Core') ].
	spec
		package: 'Mapless-Memory-Tests'
		with: [ spec requires: #('Mapless-Memory-Core') ].

]

{ #category : #baseline }
BaselineOfMapless >> setUpMongoDependencies: spec [

	spec baseline: 'MongoTalk' with: [ 
		spec
			repository: 'github://pharo-nosql/mongotalk:v2.0/mc';
			loads: #( Client 'Mongo-DriverLegacy' ) ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpMongoPackages: spec [
	spec
		package: 'Mapless-Mongo-Core'
		with: [ spec requires: #('Mapless-Base-Core' 'MongoTalk') ].
	spec
		package: 'Mapless-Mongo-Tests'
		with: [ spec requires: #('Mapless-Mongo-Core' 'Mapless-Tests-Base') ].
	spec
		package: 'Mapless-Mongo-Log'
		with: [ spec requires: #('Mapless-Mongo-Tests' 'NeoJSON') ].
	spec
		package: 'Mapless-Benchmark-Core'
		with: [ spec requires: 'Mapless-Mongo-Tests' ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpPackages: spec [
	self setUpBaseDependencies: spec.
	self setUpBasePackages: spec.
	
	self setUpMongoDependencies: spec.
	self setUpMongoPackages: spec.
	
	self setUpRedisDependencies: spec.
	self setUpRedisPackages: spec.
	
	self setUpPostgresDependencies: spec.
	self setUpPostgresPackages: spec.
	
	self setUpSQLiteDependencies: spec.
	self setUpSQLitePackages: spec.

	self setUpUnQLiteDependencies: spec.
	self setUpUnQLitePackages: spec
]

{ #category : #baseline }
BaselineOfMapless >> setUpPostgresDependencies: spec [
	spec baseline: 'P3' with: [ spec repository: 'github://svenvc/P3:v1.4' ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpPostgresPackages: spec [
	spec
		package: 'Mapless-Postgres-Core'
		with: [ spec requires: #('Mapless-Base-Core' 'P3') ].
	spec
		package: 'Mapless-Postgres-Tests'
		with: [ spec requires: #('Mapless-Postgres-Core' 'Mapless-Tests-Base') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpRedisDependencies: spec [
	spec
		baseline: 'RediStick'
		with: [ spec
				repository: 'github://mumez/RediStick:v2.5.0/repository';
				loads: #('Core' 'ConnectionPool') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpRedisPackages: spec [

	spec
		package: 'Mapless-Redis'
		with: [ spec requires: #( 'Mapless-Base-Core' 'RediStick' ) ].

	spec
		package: 'Mapless-Redis-Observer'
		with: [ spec requires: #( 'Mapless-Base-Core' ) ].

	spec package: 'Mapless-Redis-Observer-Tests' with: [ 
		spec requires: #( 'Mapless-Redis-Observer' 'Mapless-Redis-Tests'
			   'Mapless-Tests-Base' ) ].
		
	spec
		package: 'Mapless-Redis-Tests'
		with: [ spec requires: #( 'Mapless-Redis' 'Mapless-Tests-Base' ) ].	
]

{ #category : #baseline }
BaselineOfMapless >> setUpSQLiteDependencies: spec [
	spec
		baseline: 'SQLite3'
		with: [ spec
				repository: 'github://pharo-rdbms/Pharo-SQLite3:v2.2.7/src';
				loads: #('Core') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpSQLitePackages: spec [
	spec
		package: 'Mapless-SQLite-Core'
		with: [ spec requires: #('Mapless-Base-Core' 'SQLite3') ].
	spec
		package: 'Mapless-SQLite-Tests'
		with: [ spec requires: #('Mapless-SQLite-Core' 'Mapless-Tests-Base') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpUnQLiteDependencies: spec [
	spec
		baseline: 'PunQLite'
		with: [ spec
				repository: 'github://mumez/PunQLite/repository';
				loads: #('Core') ]
]

{ #category : #baseline }
BaselineOfMapless >> setUpUnQLitePackages: spec [
	spec
		package: 'Mapless-UnQLite-Core'
		with: [ spec requires: #('Mapless-Base-Core' 'PunQLite') ].
	spec
		package: 'Mapless-UnQLite-Tests'
		with: [ spec requires: #('Mapless-UnQLite-Core' 'Mapless-Tests-Base') ]
]
