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