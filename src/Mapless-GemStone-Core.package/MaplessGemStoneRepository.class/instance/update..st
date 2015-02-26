actions
update: aMapless
  self onBeforeUpdate: aMapless.
  (self databaseCollectionNamed: aMapless class name asString)
    at: (self idOf: aMapless)
    put: aMapless.
  self onAfterUpdate: aMapless