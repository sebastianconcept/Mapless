A MaplessRepository is an abstraction for all the repository supported by Mapless. Subclasses are concrete strategies for having Mapless supported by each repository.

Instance Variables
	database:	holds the backend connection. It gets instantiated using the class message #on:

Look for the subclasses for concrete implementation details.

