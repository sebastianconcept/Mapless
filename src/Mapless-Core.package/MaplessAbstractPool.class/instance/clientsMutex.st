accessing
clientsMutex
	"Answers the mutex used to protect clients usage"
	^ clientsMutex ifNil: [self initializeClientsMutex]