# Simplicité build process

To simplify, this document focuses on main version: v5, release, not light

## Build templates

On `dev.simplicite.io`, run `u5r` (update v5 release) which will update the `git.simplicite.io:/var/git/platform/template-5.git` repository.

`u5r` is an alias to `sudo su - template5 -c 'nice /var/simplicite/utils/simplicite/upgrade-template-5.sh release'`

The template creation (`git.simplicite.io:/var/git/utils.git:simplicite/upgrade-template-5.sh`):
- selects & checks out the simplicité branch (`master`)
- calls the `ant instance.upgrade` (with necessary exclusions for example for the **light version)**
- instructs on template database upgrade script if necessary (meta-model modification)

## Build docker images

On `registry.simplicite.io` run `build-platform-5.sh [alpha|beta|latest]` which runs `build-platform.sh --delete 5-latest` and pushes to registries.

The build-platform.sh script :
- checks out the last appropriate Simplicité Template
- adapts the template for docker :
    - adapts simplicité logging to docker loggine by updating log4j config
    - generates oracle & SQLServer scripts
- detects platform's {version, patchlevel, revision, commitid} from `$TEMPLATE/app/WEB-INF/classes/com/simplicite/globals.properties`
- executes a docker build based on Dockerfile-platform with the corresponding `build-arg`
    - date
    - tag
    - version
    - branch
    - patchlevel
    - revision
    - comitid
    - template

## How to build image

- copy JVM to `/usr/local/jvm`
- copy tomcat to `/usr/local/tomcat`
- copy run script to `/usr/local/tomcat/run`
- copy certificates to `/usr/local/share/ca-certificates/`
- 

