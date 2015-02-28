A ConfigurationFiles is a helper to access the configuration files expected to be in the conf subdirectory of this image. 

This helper will assume that configuration files are those in that /conf dir and having `.conf` extension. 

These files should be normal smalltalk code and they should compile returning a Dictionary-like object (they need to answer to #at:).

The rest is responsibility of the applications using it.