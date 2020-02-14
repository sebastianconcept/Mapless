baseline
baseline: spec
	<baseline>
	spec
		for: #common
		do: [ spec blessing: #release.
			self dependencies: spec.
			self projectPackages: spec ]