
May 18, 2022 | v0.5.2-alpha | Major Bird
===================================
- `MongoChange` `type` is now uppercase for client convenience.
- Added `maplessClass` accessor in `Mapless` and `MaplessReference`.

May 11, 2022 | v0.5.1-alpha | Tense Eagle
===================================
* Added `MaplessMongoObserver` to give to the Mongo repositories, the capability of logging database changes. It will use an auto-incremented `MongoChangeSequence` to log `MongoChange` that can later be used to synchronize database state in different installations. `MongoChange` would have an entry only for `insert`, `update` and `delete` events. No other Mongo command will be logged.

April 23, 2022 
===================================
* Added a nice README header thanks to Luis Poletti.

April 15, 2022 
===================================
* Added `MaplessUnQLiteRepository>>inMemory` methods to make use of RAM based storage offered by UnQLite.
* Added `testSimpleSaveAndLoadInMemory` for elemental coverage.

April 6, 2022 
===================================
* Removed the docker directory with a replica set docker-compose.yml. This is better done when using your own or https://github.com/sebastianconcept/mongo-rs.
* Starting to improve README based on https://github.com/sebastianconcept/Mapless/issues/87.

April 3, 2022 
===================================
* Adds `MaplessUnQLiteCursor` to provide basic navigation of the database treating values as `Mapless`. 
* Adds `testSeekGreaterThan` and `testSeekGreaterThan` for cursor positioning.
* Adds `fromCurrentDoEach:` and  `fromCurrentReverseDoEach:` for iterating `Mapless` objects.
* All tests green.

March 30, 2022 
===================================
* Introducing `MaplessPostgresRepository` via dependency on [P3](https://github.com/svenvc/P3).
* Adds all minimal coverage.
* All tests green.

March 25, 2022 
===================================
* Using `(resolver conditionForClass: aMaplessClass)`  in all class based `MongoDB` queries, so the query doesn't bring any document in that collection that isn't strictly that `Mapless` class.
* Fixed `MaplessMemoryRepository` to return its own general condition to query all mapless of a given class using its new `MaplessMemoryCollectionToClassNameResolver` in `resolver conditionForClass: aMaplessClass` expressions.
* Adapted and fixed tests.

March 23, 2022 | v0.5.0-alpha | Double Citadel
===================================
* Introduces `MaplessRedisRepository` via dependency on [RediStick](https://github.com/mumez/RediStick).
* Extends API to use write concerns in all queries of `MaplessMongoRepository`
* Introduces and extends existing API to use `MongoReadConcerns` in all queries.
* Improves general API consistency.

March 4, 2022 | v0.4.12-alpha | Jolly Adjustment
===================================
* Fixed usage of concerns in `MaplessMongoRepository>>save:`.

February 14, 2022 | v0.4.10-alpha | Confidential Star
===================================
* Implemented `save` using `insert` and `update` for `MongoDB` after reviewing subperforming benchmark results https://github.com/sebastianconcept/Mapless/issues/69
* Added `MaplessMongoReplicaSetTest` as a subclass of `MaplessMongoTest` so all the tests for a standalone MongoDB can be run on a replica set.
* Adds convenience scripts to start a replica set using `Docker`. For persistence it will use a local directory expected to be in `~/mongo` with three sub directories, one per each node: `~/mongo/node1`, `~/mongo/node2` and `~/mongo/node3`. The id of that test replica set is `dbrs`. To start it you can use the bash script `docker/startdb.sh`.
* Removes obsolete files.

December 6, 2021
===================================
* Being less strict about the conditions to answer true on `isVoyageReference: anObject in: aMaplessRepository` and `canRepresentSubMapless: anObject in: aMaplessRepository` in order to make `Mapless` able to interoperate with `Voyage`.
* Using resolver's help to make `Mapless` and `MaplessReference` to be returned `asStorable:`.
* `MaplessVoyageWithMaplessSuffixResolver` now uses `referenceAsJsonObject: anObject in: aMaplessRepository` to implement a mapless data object that is compatible with Voyage. Just before a save this method is used by Mapless and now it's being used, beside the usual, including Voyage metadata making both Voyage and Mapless able to achieve interoperability.

November 16, 2021 - v0.4.9-alpha | New Eagle
===================================
* Pushed a re-designed version of `MaplessMongoReplicaSetPool`. A `MaplessMongoRepository` now will be resilient to primary node changes.
* `MaplessMongoReplicaSetPool` will use the secondary nodes for read-only operations and the primary node for the read-write operations.
* Adds some UML diagrams covering the normal and MongoDB primary node failing cases.

October 20, 2021
===================================
* Using `Monitor` instead of `Mutex` in the client pool.
* Introduces strategy for getting clients `MaplessMongoReplicaSetClientSelectionPolicy` and the concrete `MaplessMongoReplicaSetReadOnlyOnSecondaries` so Mapless on Mongo will read-only from secondaries and write in the primary.
* Introduces `MaplessMongoRepository` with `readWriteDo:` and `readOnlyDo:`. All operations are going to use one or the other accordingly.
* Introduces `MaplessUnavailableMaster` exception which would be used when a MongoDB Replica Set is not having a primary or the primary changed and a new one is getting elected.
* The previous MongoDB pool is now `MaplessStandaloneMongoPool`.
* `findOne: aMaplessClass where:` is based in the cursor with the right read concern and working in secondaries.

October 6, 2021
===================================
* `MaplessMongoRepository` is now using `MongoCommandCursor` which is created using `setFlagSlaveOk`. This makes Mapless able to read documents from secondary nodes in a MongoDB replica set.

September 28, 2021
===================================
* Completes the API.
* Default concerns can be set at the repository level.
* Concerns can be custom per Mapless class.
* Adds basic coverage.

September 27, 2021
===================================
* Adds API to do operations with custom concerns.
* Adjusts `upsert` command for MongoDB 4.0.
* Adds `testUpsert` for coverage.

September 26, 2021
===================================
* Will raise an exception when trying to insert a mapless with a duplicate value on indices with unique values.

September 22, 2021
===================================
* Introduces `MaplessResolver` to collaborate with `MaplessRepository` on getting the `Mapless` from JSON and return `MaplessReference`.
* Aditional unit tests.
* One of the resolvers, `MaplessVoyageWithMaplessSuffixResolver` helps with using `Mapless` to connect a MongoDB backend created or in use by a Voyage app.

September 21, 2021
===================================
* Now a `Mapless` coming from data from Voyage, can have a Voyage reference reified as a `MaplessReference`.

September 20, 2021 - v0.4.3-alpha | Hidden Alpha
===================================
* Introduces mainly the optional usage of the dynamic variable.
* Multi repo usage becomes cleaner now.
* Fixes unit tests.
* Simplifies use of the id property name. Now it won't need to manipulate the id anymore.

September 14, 2021 v0.4.2-alpha | Eastern Panther
===================================
* Hotfix to make it compatible with Pharo 7.

September 11, 2021 🇺🇸 😔 🙏 #NeverForget
===================================
* Made reposotories API consistent. No mode `instanceOf` kind of messages. The whole API feels inspired in MongoDB.
* Fixed setters. Now they return the receiver instead of the value that was set.
* Added `find:where:sort` and all the `*sort:` variations for the API.

September 8, 2021
===================================
* Added `count` and `count:where:` with basic coverage.
* Added basic coverage showing usage of MongoTalk-Queries in the `Mapless class>>find:` argument.

September 1st, 2021
===================================
* Fixed `BaslineOfMapless` missing Memory package.

August 28, 2021
===================================
* Adds `MaplessMemoryRepository` its accessor and unit test for regression coverage.

August 27, 2021 - 0.4.0-alpha
===================================

* Introducing another non-backward compatible change: the metadata we used to call `maplessClass` is now found as `_c` in the mongo documents. This has a nice impact by making Mapless to send less self-serving content over the wire without loosing features or introducing complexity. If you need help migrating from a previous version please contact the maintainers.
* Removes the `raw` instance variable as is not really needed.
* Makes internal API more consistent and removes deprecations and redundancies.

August 25, 2021
===================================

* Removed deprecated methods.
* Added a `develop` branch for converging all the progress of the project roadmap in it while preserving in the `master` branch only the production-ready code, release candidate commits and fixes.
* Mades `MaplessMongoRepository` able to drop its database.
* Made the pools have a `maxClient` value to prevent resource abuse under usage storms.
* Made the pools have a warm up to connect N clients right from the start.
* Introducing non-backward compatible changes: what we used to call `modelClass` is now `maplessClass` to get rid of naming ambiguity.

August 23, 2021
===================================

* Added MaplessLongevityTester in order to run long lasting tests with read/write load and consistency check when using MongoDB.
* Reorganized classes in packages and updated BaselineOfMapless.
* Removed unused dummy classes.

August 8, 2021
===================================

* Made MaplessMongoRepository to have the current mongo client used during the `#do:` thread/operation so the database and any other operation is taken from that very client (hence socket stream).
* Fixed all tests and MaplessMongoBenchmark

August 5, 2021
===================================

* The Mapless id is now using OID's so they take advantage of the BSON serialization of ObjectId.
* Fixed all tests but testSubModelsFromReifiedJSON 

August 4, 2021
===================================

* Fixed isUsingAuth. All test green.
* Updated readme file.

March 2, 2015 - Release 0.2.8
===================================

* Refactored the code into many packages (as opposed to one monolithic package) in order to simplify mainteinance and sync with GemStone and any other repositories. 


February 20, 2015 - Release 0.2.6
===================================

* Introducing basic Postgres support (requires Postgres 9.4)
* find: someConditions will make `someConditions` to be coupled with the backend. If you are using MongoDB, they are going to be the dictionary you would send to Mongo, if you are using Postgres, it would be the clause coming just after the where in: `SELECT * FROM maplessClassName WHERE `


February 18, 2015 - Release 0.2.5
===================================

* Mapless now normalizes the server id to the attribute `id` but each repository migth briefly move that to their own flavor. For example MongoDB uses `_id` and Redis uses `oid`


February 7, 2015 - Release 0.2.4
===================================

* Includes repository refactoring
* Fixed hooks and added tests
* Adds support for #dateAndTimeAt: comming from a Mongo export like: {'$date':1412279266711}
* Makes sure code is in sync with Smalltalkhub version


February 2, 2015 - Release 0.2.3
===================================

* Facundo's refactoring decouples Mapless models from the concrete repository supporting their persistence.


January 24, 2015 - Release 0.2.2
===================================

* Merged from SmalltalkHub
* First release intended to be shared and ported to other environments.

Previous history is in the git commits.

To give some historical context, before having its own repository and being used as part of the flow stack, this framework was used for some private projects.