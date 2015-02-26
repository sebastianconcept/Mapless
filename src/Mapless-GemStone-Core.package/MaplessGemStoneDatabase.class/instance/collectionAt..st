other
collectionAt: aString 
	"Answers the collection in this database that has aString as name (or nil)"

	^ self collections at: aString ifAbsent:[]