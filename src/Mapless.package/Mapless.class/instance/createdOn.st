accessing
createdOn 

	| selector expects object |

	selector := #createdOn.
	expects := DateAndTime.

	object := self at: selector asString.
	(object isNil or: [
	object isDictionary and: [
	object isEmpty ]]) ifTrue: [^nil].

	(object isKindOf: expects) ifTrue: [ ^ object ].

	^ self at: selector asString put: (self dateAndTimeAt: selector)
