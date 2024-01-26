![Mapless](./header.png)

# Mapless

Schema-less persistence for Smalltalk with support for multiple backends.

[![Unit Tests](https://github.com/sebastianconcept/Mapless/actions/workflows/build.yml/badge.svg)](https://github.com/sebastianconcept/Mapless/actions/workflows/build.yml)
![Tests](https://img.shields.io/badge/tests-193-green)
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
- Multiple backends to choose from.
- Enables smooth data migration/interoperation among backends.
- ~~Via Redis PUB/SUB, scalable observer-pattern functionality across images.~~ In the roadmap.

## Description

Mapless is a schema-less persistence framework supporting multiple backends and offering a user-friendly API. For instance, querying Mapless objects involves a common family of methods, and there's no need to declare accessors and mutators. See [examples below](#examples).

Designed to be schema-less, Mapless eliminates the need for schema maintenance and avoids any Object-Relational Mapping requirements.

Mapless achieves a balance of maximum data survivability and robust architectural flexibility without imposing a heavy burden in terms of adoption and maintenance.

## Ambition

To deliver a high-performance solution that preserves arbitrary application state (data) with a focus on flexibility, availability, and capacity. It aims to strategically aid in scaling without causing backend vendor lock-in, across various persistence backends, and by neutralizing the costs associated with object-mapping impedance mismatch.

## Supported backends

1. MongoDB
2. Redis
3. Memory
4. PostgreSQL
5. ~~UnQLite~~ `deprecated` / retiring soon

## Examples

```Smalltalk
"Instanciates a mapless object."
philosopher := Person new
	firstName: 'Aristotle';
	yourself.

"Saves it."
repository save: philosopher.
```

```Smalltalk
"Loads one by known ID."
identified := repository findOne: Person atId: philosopher id.
```

```Smalltalk
"Loads all instances of that class that were stored in that database."
allOrEmpty := repository findAll: Person.
```

```Smalltalk
"Query to load all the instances that match the condition."
someOrEmpty := repository findAll: Person where: [ :each | each lastName = 'Peterson' ].
```

```Smalltalk
"Conditionally loading the first matching instance."
oneOrNil := repository findOne: Person where: [ :each | each lastName = 'Peterson' ].
```

```Smalltalk
"Create a Person mapless model"
philosopher := Person new
	firstName: 'Aristotle';
	save.

"Set it as the person for a new User mapless model"
philosopherUser := User new
	person: philosopher;
	save.  

"Query for that user by ID and get its person instance"
aristotle := (User findId: philosopherUser id) person.
```
## Installation

Open a workspace in a supported Pharo image and evaluate:

```smalltalk
Metacello new
  baseline: 'Mapless';
  repository: 'github://sebastianconcept/Mapless:latest/src';
  load
```

## Include as dependency

In BaselineOf or ConfigurationOf it can be added in this way:

```smalltalk
spec
  baseline: 'Mapless'
    with: [ spec
    repository: 'github://sebastianconcept/Mapless:latest/src';
    load: #('Core' 'Postgres' 'Mongo' 'Redis' 'Memory') ]
```
