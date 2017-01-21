accessing
findAllSortedBy: aSelector
	"Answers all instances or ans empty set.
	Note: this is only a good idea when you have very few of this objects
	and starts to become a REALLY BAD idea when you have, for instance, more than 1000."

	|answer|

	answer := TreeSet sortSelector: aSelector equalitySelector: #=.
	self modelClasses do:[:aModelClass|
		aModelClass == Mapless ifFalse:[
			answer addAll: aModelClass findAll]].

	^ answer