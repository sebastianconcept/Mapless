initialization
initializeIdAttribute
	"Uses '_id' as default because we're using MongoDB and that's what it uses as id."

	^ idAttribute := '_id'