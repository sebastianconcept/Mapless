![Mapless](./header.png)

# Mapless

Schema-less persistence for Smalltalk with support for multiple backends.

[![Unit Tests](https://github.com/sebastianconcept/Mapless/actions/workflows/build.yml/badge.svg)](https://github.com/sebastianconcept/Mapless/actions/workflows/build.yml)
![Tests](https://img.shields.io/badge/tests-178-green)
[![Coverage Status](https://codecov.io/github/sebastianconcept/Mapless/coverage.svg?branch=main)](https://codecov.io/gh/sebastianconcept/Mapless/branch/master)

[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE.txt)
[![Release](https://img.shields.io/github/v/tag/sebastianconcept/Mapless?label=release)](https://github.com/sebastianconcept/Mapless/releases)


[![Pharo 7](https://img.shields.io/badge/Pharo-7-%23383932.svg)](https://pharo.org/download)
[![Pharo 10](https://img.shields.io/badge/Pharo-10-%23383932.svg)](https://pharo.org/download)

[![Social](https://img.shields.io/github/stars/sebastianconcept/Mapless?style=social)]()
[![Forks](https://img.shields.io/github/forks/sebastianconcept/Mapless?style=sociall)]()

---

## Features

- Intuitive API for frictionless persistence.
- No need to create and maintain schemas.
- Composable.
- JSON friendly.
- No need to create accessors and mutators.
- Multiple backends to chose from.
- Enables smooth data migration/interoperation among backends.
- ~~Via Redis PUB/SUB, scalable observer-pattern functionality across images.~~ In the roadmap.

## Ambition

Mapless gives you performant state plasticity and high availability in a scale that goes beyond one Smalltalk image and without backend vendor locking nor object-mapping impedance mismatch.

## Supported backends

1. MongoDB
2. Redis
3. Memory
4. PostgreSQL
5. ~~UnQLite~~ `deprecated` / retiring soon

## Examples

```Smalltalk
"Instanciates a mapless object."
genius := DummyPerson new
	firstName: 'Aristotle';
	yourself.

"Saves it."
repository save: genius.
```

```Smalltalk
"Loads one by known ID."
identified := repository findOne: DummyPerson atId: genius id.
```

```Smalltalk
"Loads all instances of that class that were stored in that database."
allOrEmpty := repository findAll: DummyPerson.
```

```Smalltalk
"Query to load all the instances that match the condition."
someOrEmpty := repository findAll: DummyPerson where: [ :each | each lastName = 'Peterson' ].
```

```Smalltalk
"Conditionally loading the first matching instance."
oneOrNil := repository findOne: DummyPerson where: [ :each | each lastName = 'Peterson' ].
```

## Installation

Open a Pharo workspace and evaluate:

```smalltalk
Metacello new
  baseline: 'Mapless';
  repository: 'github://sebastianconcept/Mapless:v0.5.7/src';
  load
```

## Include as dependency

In BaselineOf or ConfigurationOf it can be added in this way:

```smalltalk
spec
  baseline: 'Mapless'
    with: [ spec
    repository: 'github://sebastianconcept/Mapless:v0.5.0-alpha/src';
    load: #('Core' 'Mongo' 'Memory' 'Redis' 'UnQLite') ]
```
