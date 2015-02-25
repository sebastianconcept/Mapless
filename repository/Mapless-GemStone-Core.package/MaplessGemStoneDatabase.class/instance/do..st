other
do: aBlock
	"Performs aBlock and provides access to the database to 
	anyone calling CurrentMongoDatabase value."
	
	CurrentMaplessDatabase
		value: self
		during: [ ^ aBlock value ]