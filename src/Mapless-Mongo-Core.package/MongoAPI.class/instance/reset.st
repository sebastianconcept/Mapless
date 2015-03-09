actions
reset 
	"Close, no fail"
	[ self close ] on: Error do: [ :x |  ] 