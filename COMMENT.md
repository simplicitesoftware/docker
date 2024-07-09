# Simplicité build process

To simplify, this document focuses on current version 6

## Build templates

On `git.simplicite.io`, run the `u6x[l]` alias (update v6.x release) which will update the `git.simplicite.io:/var/git/platform/template-6.git` repository.

This template update script:

- selects & checks out the concerned branch
- calls the `ant instance.upgrade` 
- gives instruction to apply database patches (not required if no patch file is altered vs previous revision)

## Build docker images

On `registry.simplicite.io` run `build-platform-6.sh [alpha|beta|latest]` which builds images and pushes them to the private registry.

This build script:

- checks out the last appropriate Simplicité template (see above)
- adapts the template for Docker :
    - adapts logging for Docker logging by updating log4j config
    - generates Oracle & SQL Server scripts
- extracts platform's version, patchlevel, revision, commitid from the template's `app/WEB-INF/classes/com/simplicite/globals.properties`
- executes a Docker build based on `Dockerfile-platform` with the corresponding `build-arg`