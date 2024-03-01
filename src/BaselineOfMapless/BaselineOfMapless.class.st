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

{ #category : #baselines }
BaselineOfMapless >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self setUpBaseDependencies: spec.
		self setUpPackages: spec.
		spec
			group: 'Core' with: #( 'Mapless-Base' );
			group: 'Tests' with: #( 'Mapless-Base' 'Mapless-Tests' );
			group: 'Memory' with: #( 'Mapless-Memory' );
			group: 'Memory-Tests'
			with: #( 'Mapless-Memory' 'Mapless-Memory-Tests' );
			group: 'Mongo' with: #( 'Mapless-Mongo' );
			group: 'Mongo-Tests'
			with: #( 'Mapless-Mongo' 'Mapless-Mongo-Tests' );
			group: 'Redis' with: #( 'Mapless-Redis' );
			group: 'Redis-Tests'
			with: #( 'Mapless-Redis' 'Mapless-Redis-Tests' );
			group: 'Redis-Observer-Tests'
			with: #( 'Mapless-Redis-Observer' 'Mapless-Redis-Observer-Tests' );
			group: 'Postgres' with: #( 'Mapless-Postgres' );
			group: 'Postgres-Tests'
			with: #( 'Mapless-Postgres' 'Mapless-Postgres-Tests' );
			group: 'SQLite' with: #( 'Mapless-SQLite' );
			group: 'SQLite-Tests'
			with: #( 'Mapless-SQLite' 'Mapless-SQLite-Tests' );
			group: 'UnQLite' with: #( 'Mapless-UnQLite' );
			group: 'UnQLite-Tests'
			with: #( 'Mapless-UnQLite' 'Mapless-UnQLite-Tests' );
			group: 'Benchmark' with: #( 'Mapless-Benchmark-Core' );
			group: 'default' with: #( 'Memory' 'SQLite' ) ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpBaseDependencies: spec [
	spec
		baseline: 'JSON'
		with: [ spec repository: 'github://sebastianconcept/JSON:v1.0.2/src' ].
	spec
		baseline: 'NeoJSON'
		with: [ spec repository: 'github://svenvc/NeoJSON:v18/repository' ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpBasePackages: spec [
	spec
		package: 'Mapless-Base'
		with: [ spec requires: 'JSON' ].
	spec
		package: 'Mapless-Tests'
		with: [ spec requires: 'Mapless-Base' ].
	spec
		package: 'Mapless-Memory'
		with: [ spec requires: #('Mapless-Base') ].
	spec
		package: 'Mapless-Memory-Tests'
		with: [ spec requires: #('Mapless-Memory') ].

]

{ #category : #dependencies }
BaselineOfMapless >> setUpMongoDependencies: spec [

	spec baseline: 'MongoTalk' with: [ 
		spec
			repository: 'github://pharo-nosql/mongotalk:v2.0/mc';
			loads: #( Client 'Mongo-DriverLegacy' ) ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpMongoPackages: spec [
	spec
		package: 'Mapless-Mongo'
		with: [ spec requires: #('Mapless-Base' 'MongoTalk') ].
	spec
		package: 'Mapless-Mongo-Tests'
		with: [ spec requires: #('Mapless-Mongo' 'Mapless-Tests') ].
	spec
		package: 'Mapless-Mongo-ReplicaSet-Tests'
		with: [ spec requires: #('Mapless-Mongo-Tests') ].
	spec
		package: 'Mapless-Mongo-Log'
		with: [ spec requires: #('Mapless-Mongo-Tests' 'NeoJSON') ].
	spec
		package: 'Mapless-Benchmark-Core'
		with: [ spec requires: 'Mapless-Mongo-Tests' ]
]

{ #category : #dependencies }
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

{ #category : #dependencies }
BaselineOfMapless >> setUpPostgresDependencies: spec [
	spec baseline: 'P3' with: [ spec repository: 'github://svenvc/P3:v1.4' ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpPostgresPackages: spec [
	spec
		package: 'Mapless-Postgres'
		with: [ spec requires: #('Mapless-Base' 'P3') ].
	spec
		package: 'Mapless-Postgres-Tests'
		with: [ spec requires: #('Mapless-Postgres' 'Mapless-Tests') ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpRedisDependencies: spec [
	spec
		baseline: 'RediStick'
		with: [ spec
				repository: 'github://mumez/RediStick:v2.5.0/repository';
				loads: #('Core' 'ConnectionPool') ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpRedisPackages: spec [

	spec
		package: 'Mapless-Redis'
		with: [ spec requires: #( 'Mapless-Base' 'RediStick' ) ].

	spec
		package: 'Mapless-Redis-Observer'
		with: [ spec requires: #( 'Mapless-Redis' ) ].

	spec package: 'Mapless-Redis-Observer-Tests' with: [
		spec requires: #( 'Mapless-Redis-Observer' 'Mapless-Redis-Tests'
			   'Mapless-Tests' ) ].

	spec
		package: 'Mapless-Redis-Tests'
		with: [ spec requires: #( 'Mapless-Redis' 'Mapless-Tests' ) ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpSQLiteDependencies: spec [
	spec
		baseline: 'SQLite3'
		with: [ spec
				repository: 'github://pharo-rdbms/Pharo-SQLite3:v2.2.7/src';
				loads: #('Core') ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpSQLitePackages: spec [
	spec
		package: 'Mapless-SQLite'
		with: [ spec requires: #('Mapless-Base' 'SQLite3') ].
	spec
		package: 'Mapless-SQLite-Tests'
		with: [ spec requires: #('Mapless-SQLite' 'Mapless-Tests') ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpUnQLiteDependencies: spec [
	spec
		baseline: 'PunQLite'
		with: [ spec
				repository: 'github://mumez/PunQLite:v2.0.1/repository';
				loads: #('Core') ]
]

{ #category : #dependencies }
BaselineOfMapless >> setUpUnQLitePackages: spec [
	spec
		package: 'Mapless-UnQLite'
		with: [ spec requires: #('Mapless-Base' 'PunQLite') ].
	spec
		package: 'Mapless-UnQLite-Tests'
		with: [ spec requires: #('Mapless-UnQLite' 'Mapless-Tests') ]
]
