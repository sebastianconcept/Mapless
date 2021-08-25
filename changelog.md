August 25, 2021
===================================

* Removed deprecated methods.
* Added a `develop` branch for converging all the progress of the project roadmap in it while preserving in the `master` branch only the production-ready code, release candidate commits and fixes.
* Mades `MaplessMongoRepository` able to drop its database.
* Made the pools have a `maxClient` value to prevent resource abuse under usage storms.
* Made the pools have a warm up to connect N clients right from the start.

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