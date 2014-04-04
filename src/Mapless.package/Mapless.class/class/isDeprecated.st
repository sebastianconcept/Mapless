testing
isDeprecated
	"Answers true if the model class is deprecated.
	Very useful for migrations after design changes.

	You can (sub) implement something like this in a deprecated class:
	
	^ self == DeprecatedModelClass"
		
	^ false