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

# Run the unit tests; Postgres, Redis, and MongoDB must be up
test: services
    smalltalkci -s {{smalltalkci_image}} {{unit_tests}}
