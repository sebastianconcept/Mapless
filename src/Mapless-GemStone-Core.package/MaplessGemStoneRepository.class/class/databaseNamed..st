as yet unclassified
databaseNamed: dbNameString
  ^ self Databases
    detect: [ :db | db name = dbNameString ]
    ifNone: [ Databases add: (MaplessGemStoneDatabase named: dbNameString) ]