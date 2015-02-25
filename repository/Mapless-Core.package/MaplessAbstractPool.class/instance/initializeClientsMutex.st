initialization
initializeClientsMutex

	^ clientsMutex := Semaphore forMutualExclusion