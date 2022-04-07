# Mapless

Multi-backend schema-less persistence for Smalltalk.

<p align="left">
	<a href="https://github.com/sebastianconcept/Mapless/releases" alt="Releases">
		<img src="https://img.shields.io/github/v/tag/sebastianconcept/Mapless?label=release" /></a>
	<a href="https://github.com/sebastianconcept/Mapless/blob/develop/LICENSE" alt="License">
		<img src="https://img.shields.io/github/license/sebastianconcept/Mapless" /></a>
	<img src="https://img.shields.io/github/stars/sebastianconcept/Mapless?style=social" />
	<img src="https://img.shields.io/github/forks/sebastianconcept/Mapless?style=social" />
</p>

___

## Mapless most **important features** are:

- Intuitive API for frictionless persistence.
- No need to create and maintain schemas.
- Composable.
- JSON friendly.
- No need to create accessors and mutators.
- Multiple backends to chose from.
- Enables smooth data migration/interoperation among backends.
- Via Redis PUB/SUB, scalable observer-pattern functionality across images.

## Supported backends
1. MongoDB
2. Redis
3. Memory
4. PostgreSQL
5. UnQLite

## Examples

### Creating repositories

```Smalltalk
"MongoDB standalone"
mongoRepository := MaplessMongoRepository
	for: 'Mapless-Test'
	with: MaplessStandaloneMongoPool local.
```

```Smalltalk
"MongoDB Replica Set"
databaseName := 'Mapless-Test'.
mongoRepository := MaplessMongoRepository
	for: databaseName
	with: (MaplessMongoReplicaSetPool mongoUrls: {
		'localhost:27017'. 
		'localhost:27019'
		}
		database: databaseName)
```

```Smalltalk
"Redis"
"Since Redis doesn't use database names, 
we use one of its 0-15 index."
databaseIndex := 3.
accessor := MaplessRedisPool local.
accessor start.
accessor auth: 'my_password'.
redisRepository := MaplessRedisRepository
	for: databaseIndex
	with: accessor
	using: MaplessTrivialResolver new
```
```Smalltalk
"UnQLite"
dbFilename := FileSystem workingDirectory / 'Mapless-Tests.db'.
unqliteRepository := MaplessUnQLiteRepository for: dbFilename pathString
```

### Saving and loading a mapless object

```Smalltalk
"Instanciates a mapless object."
guy := DummyPerson new
	firstName: 'Aristotle';
	yourself.

"Saves it."
repository save: guy.	

"Loads one by known ID."
identified := repository findOne: DummyPerson atId: guy id.

"Loads all instances of that class that were stored in that database."
all := repository findAll: DummyPerson.

"Query to load all the instances that match the condition (or receive an empty collection)."
some := repository findAll: DummyPerson where: [ :each | lastName = 'Peterson' ].

"Conditionally loading one instance (or nil)."
one := repository findOne: DummyPerson where: [ :each | lastName = 'Peterson' ].
```

## Installation

Open a Pharo workspace and evaluate:

	Metacello new
		baseline: 'Mapless';
		repository: 'github://sebastianconcept/Mapless:v0.5.0-alpha/src';
		load

## Include as dependency
Add it like this your own project's BaselineOf or ConfigurationOf 

	spec
		baseline: 'Mapless'
		with: [ spec
				repository: 'github://sebastianconcept/Mapless:v0.5.0-alpha/src';
				loads: #('Core' 'Mongo' 'Memory' 'Redis' 'UnQLite') ]