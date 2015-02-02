actions
setSubModelReferencesAt: aKey with: anObject 

	"1. It's a submodel"	
	(anObject isString and:[
	('*oid*' match: anObject) and:[
	('*modelClass*' match: anObject) ] ] )  ifTrue:[ 
		self setReferenceFrom: anObject on: aKey of: self data ].
	
	"2. it's a collection of submodels"
	(anObject isCollection and:[
	anObject notEmpty and:[
	(anObject allSatisfy: [:e| e isString ]) and:[|any|
	any := anObject anyOne.
	('*oid*' match: any) and:[
	('*modelClass*' match: any)]]]]) ifTrue:[
		self setReferencesFrom: anObject on: aKey of: self data].
