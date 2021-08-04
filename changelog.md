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