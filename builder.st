Metacello new
        repository: 'tonel://./src'; "No git or git repository inside docker, just the src folder"
        baseline: 'Mapless';
        onConflictUseIncoming;
        load.

Smalltalk saveSession.
