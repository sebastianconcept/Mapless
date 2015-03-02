other
databaseAt: aDatabaseName do: aBlock

	  CurrentMaplessDatabase value: (self databaseAt: aDatabaseName) during:[ ^aBlock value ]