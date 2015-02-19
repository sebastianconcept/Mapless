actions
ifUnavailablePurge: aPostgressConnection
	"Tests aPostgressConnection and remove it from this pool if invalid."

	aPostgressConnection isConnected ifFalse:[ self remove:  aPostgressConnection]