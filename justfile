set shell := ["bash", "-cu"]

compose_file := "docker/docker-compose.yml"
smalltalkci_image := "Pharo64-11"
unit_tests := ".smalltalkci/.unit-tests.ston"

# List the available recipes
[private]
default:
    @just --list

# Get a fresh Pharo image and load Mapless
build:
    #!/usr/bin/env bash
    echo "Downloading fresh Pharo image and a VM ..."
    curl get.pharo.org | bash
    echo "Opening Pharo to load Mapless ..."
    script="$(mktemp --suffix=.st)"
    trap 'rm -f "$script"' EXIT
    cat > "$script" <<'SMALLTALK'
    Metacello new
            repository: 'tonel://./src'; "No git or git repository inside docker, just the src folder"
            baseline: 'Mapless';
            onConflictUseIncoming;
            load.

    Smalltalk saveSession.
    SMALLTALK
    ./pharo-ui Pharo.image "$script"
    echo "Ready!"

# Remove downloaded VMs, launchers, logs, and caches
clean:
    #!/usr/bin/env bash
    rm -rf pharo
    rm -rf pharo-ui
    rm -rf *.log
    rm -rf pharo-vm
    just clean-caches

# Remove package and GitHub caches
clean-caches:
    rm -rf package-cache
    rm -rf github-cache

# Clean local build artifacts, then get a fresh Pharo image and load Mapless
clean-build:
    #!/usr/bin/env bash
    just clean
    just build

# Start Postgres, Redis, and MongoDB for the unit tests
services:
    docker compose -f {{compose_file}} up -d --wait

# Run the unit tests with SmalltalkCI; Postgres, Redis, and MongoDB must be up
test: services
    smalltalkci -s {{smalltalkci_image}} {{unit_tests}}

# Run the same unit-test groups in the local Pharo image against the Docker backends
test-image: services
    #!/usr/bin/env bash
    set -euo pipefail
    test -x ./pharo
    test -f Pharo.image
    script="${TMPDIR:-/tmp}/mapless-tests-$$.st"
    trap 'rm -f "$script"' EXIT
    cat > "$script" <<SMALLTALK
    | repository groups suite result out |
    repository := 'tonel://$(pwd)/src'.
    #( BaselineOfMapless BaselineOfSQLite3 ) do: [ :name |
      (Smalltalk classNamed: name) ifNotNil: [ :baseline |
        baseline package removeFromSystem ] ].
    groups := #(
      'Core' 'Tests' 'Memory-Tests' 'SQLite-Tests' 'Behavior-Tests'
      'Behavior-Mongo-Tests' 'Behavior-Postgres-Tests' 'Behavior-Redis-Tests'
      'Postgres-Tests' 'Mongo-Tests'
      'Redis-Tests' 'Redis-Observer-Tests' 'UnQLite-Tests' ).
    Metacello new
      baseline: 'Mapless';
      repository: repository;
      onConflictUseIncoming;
      load: groups.
    suite := TestSuite named: 'Mapless'.
    (TestCase allSubclasses select: [ :each |
      each isAbstract not and: [ each package name beginsWith: 'Mapless-' ] ])
      do: [ :each | suite addTests: each buildSuite tests ].
    result := suite run.
    out := Stdio stdout.
    out << 'run='; print: result runCount; lf.
    out << 'passed='; print: result passedCount; lf.
    out << 'failures='; print: result failureCount; lf.
    out << 'errors='; print: result errorCount; lf.
    result failures , result errors do: [ :testCase |
      [ testCase runCase ]
        on: Error, TestFailure
        do: [ :ex |
          out << testCase class name << '>>#' << testCase selector; lf.
          out << ex class name << ': ' << ex messageText; lf ] ].
    (result hasFailures or: [ result hasErrors ])
      ifTrue: [ Smalltalk exit: 1 ]
      ifFalse: [ Smalltalk exit: 0 ].
    SMALLTALK
    ./pharo Pharo.image st "$script"
