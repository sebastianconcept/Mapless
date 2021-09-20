"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestMaplessMongoTests,
	#superclass : #PackageManifest,
	#category : #'Mapless-Mongo-Tests-Manifest'
}

{ #category : #'code-critics' }
ManifestMaplessMongoTests class >> ruleRBSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Mapless-Mongo-Tests')) #'2021-09-18T00:10:59.943159-03:00') )
]
