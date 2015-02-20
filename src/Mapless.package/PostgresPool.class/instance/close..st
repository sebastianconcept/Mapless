actions
close: aPostgressConnection

	aPostgressConnection isConnected ifTrue: [
		aPostgressConnection flushAll; quit ]