other
createDatabaseNamed: aString ifPresent: aBlock
  self addDatabase: (MaplessGemStoneDatabase named: aString) ifPresent: aBlock