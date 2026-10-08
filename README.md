![Mapless](./hero.jpg)

# Mapless

Schema-less persistence for Smalltalk with support for multiple backends.

[![Release](https://img.shields.io/github/v/tag/sebastianconcept/Mapless?label=release)](https://github.com/sebastianconcept/Mapless/releases)
[![Unit Tests](https://github.com/sebastianconcept/Mapless/actions/workflows/build.yml/badge.svg)](https://github.com/sebastianconcept/Mapless/actions/workflows/build.yml)

[![Coverage Status](https://codecov.io/github/sebastianconcept/Mapless/coverage.svg?branch=main)](https://codecov.io/gh/sebastianconcept/Mapless/branch/master)
![Tests](https://img.shields.io/badge/tests-193-green)


[![Pharo 11](https://img.shields.io/badge/Pharo-11-%23383932.svg)](https://pharo.org/download)
[![Pharo 10](https://img.shields.io/badge/Pharo-10-%23383932.svg)](https://pharo.org/download)

[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE.txt)
[![Forks](https://img.shields.io/github/forks/sebastianconcept/Mapless?style=sociall)]()
[![Social](https://img.shields.io/github/stars/sebastianconcept/Mapless?style=social)]()

[![](https://img.shields.io/badge/Sqlite-044a64?logo=sqlite&logoColor=white)](https://www.sqlite.org/index.html)
[![](https://img.shields.io/badge/PostgreSQL-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![](https://img.shields.io/badge/UnQlite-003127?logo=unqlite&logoColor=white)](https://unqlite.org/)
[![](https://img.shields.io/badge/MongoDB-001e2b?logo=mongodb&logoColor=13aa52)](https://www.mongodb.com/)
[![](https://img.shields.io/badge/RAM-001B57)](https://en.wikipedia.org/wiki/Random-access_memory)
[![](https://img.shields.io/badge/redis-CC0000.svg?logo=redis&logoColor=white)](https://redis.io/)

### [Mapless GitHub Page](https://sebastianconcept.github.io/Mapless/)

- [How to Install](#how-to-install)
- [Guides](https://sebastianconcept.github.io/Mapless#guides)

---

## Description

Mapless is a schema-less persistence framework supporting multiple backends and offering a user-friendly API. Querying Mapless objects involves a common family of methods, and there's no need to declare accessors and mutators. See [examples below](#examples).

Designed to eliminate the need for schema maintenance, Mapless avoids any Object-Relational Mapping requirements.

Mapless achieves a balance between maximum data survivability and robust architectural flexibility without imposing a heavy burden in terms of adoption and maintenance. A sweet spot for development and production.

## Features

- Intuitive API for frictionless persistence.
- No need to create and maintain schemas.
- Composable.
- JSON friendly.
- No need to create accessors and mutators.
- Multiple backends to choose from.
- Enables smooth data migration/interoperation among backends.
- [Scalable observer-pattern](https://sebastianconcept.github.io/Mapless/guides/2024/01/28/observer-pattern.html) functionality across images (requires Redis).

## Supported backends

1. SQLite
2. PostgreSQL
3. Redis
4. MongoDB
5. Memory
6. UnQLite (frozen support)

## Examples
Try Mapless by [installing it in a supported Pharo image](#how-to-install) and the following snippets:

```Smalltalk
"Instantiates an SQLite Mapless repository."
repository := MaplessSQLiteRepository
    for: 'TryMapless'
    on: 'path/string/to/your/sqlite.db'.
```

```Smalltalk
"Custom class to model your data"
Mapless subclass: #Person
	instanceVariableNames: ''
	classVariableNames: ''
	package: 'YourApp-Mapless'

"Guarantees the database has a Person table (this is idempotent)."
repository ensureTableFor: Person.

"Instantiates a Mapless object."
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
someOrEmpty := repository findAll: Person where: [ :each | 
  each firstName = 'Aristotle' ].
```

```Smalltalk
"Conditionally loading the first matching instance."
oneOrNil := repository findOne: Person where: [ :each | 
  each firstName = 'Aristotle' ].
```

```Smalltalk
"Create a Person Mapless model"
philosopher := Person new
	firstName: 'Aristotle';
	save.

"Set it as the person for a new User Mapless model"
philosopherUser := User new
	person: philosopher;
	save.  

"Query for that user by ID and get its person instance"
aristotle := (User findId: philosopherUser id) person.
```
## How to install

To start with Mapless, download Pharo, open a Pharo Playground and evaluate:

```smalltalk
"Load latest version of Mapless with its default backends (Memory and SQLite)"
Metacello new
  baseline: 'Mapless';
  repository: 'github://sebastianconcept/Mapless:latest/src';
  load.
```
```smalltalk
"Load latest version of Mapless specifying which backends explicitely"
Metacello new
  baseline: 'Mapless';
  repository: 'github://sebastianconcept/Mapless:latest/src';
  load: #('Core' 'SQLite' 'Postgres' 'Mongo' 'Redis' 'Memory') 
```

## Include as dependency

To include Mapless as a dependency from `BaselineOf` or `ConfigurationOf` add it with:

```smalltalk
spec
  baseline: 'Mapless'
    with: [ spec
    repository: 'github://sebastianconcept/Mapless:latest/src';
    load: #('Core' 'SQLite' 'Postgres' 'Mongo' 'Redis' 'Memory') ]
```
## Project Ambition

To deliver a high-performance solution that preserves arbitrary application state (data) with a focus on flexibility, availability, and capacity. It aims to strategically aid in scaling without causing vendor lock-in, across various persistence backends, and by neutralizing the costs associated with object-mapping impedance mismatch.
