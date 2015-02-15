accessing
idAttribute
	"Answers the attribute name for the id used by the backend.
	Different persistance backends might use different names.
	For example: '_id'  'id'  'oid'  etc"

	^ self currentRepository idAttribute 