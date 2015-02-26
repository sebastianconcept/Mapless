testing
isExpired: aCacheSlot for: aDuration
	"Answers true if aCacheSlot is expired for the given aDuration"
	
	^ (aCacheSlot hotOn + aDuration) > DateAndTime now