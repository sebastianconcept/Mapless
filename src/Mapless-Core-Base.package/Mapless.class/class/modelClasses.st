accessing
modelClasses
	"Answers the set of classes which are concrete model classes.
	Note: deprecated or abstract ones are going to be excluded"

	^ self withAllSubclasses reject: [ :aClass | aClass isAbstract or: [ aClass isDeprecated ] ]