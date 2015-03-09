accessing
instanceOf: aMaplessClass where: someConditions
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |

	result :=  self instancesOf: aMaplessClass where: someConditions.

	^ result isEmpty
		ifTrue: [ nil ]
		ifFalse: [ result first ]