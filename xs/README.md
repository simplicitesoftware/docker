# XS = Extra Small, Extra Secure

- simplicité docker images are at the moment:
    - not multi-arch (arm64 & amd64)
    - large (~1.3GB)
    - not "secure by default"
- this is an experiment adress this issues, the proposed solution is as follows:
    - multi-arch:
        1. build on arm
        2. [TODO] build for multi-arch
    - lightweight:
        - alpine
        - custom JDK
    - secure by default
        - alpine (smaller attack surface)
        - [TODO] implement security guide **by default**

## Base image 

- Alpine is the industry standard for lightweight images and **explicitely reccomended by Docker** in its [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#dockerfile-instructions)
- it's available for arm & x86
- `--no-cache` allows for using a temporary up-to-date cache for the installed packages. it's available for `apk upgrade` and `apk add`
- as of 2022/02/25, running `apk upgrade --no-cache` only adds 4MB. A better approach would be to build an alpine base image:
    - no, upgrading is **NOT** optionnal : https://pythonspeed.com/articles/security-updates-in-docker/
    - https://docs.docker.com/develop/develop-images/baseimages/
    - https://github.com/skwashd/alpine-docker-from-scratch

## Custom HealthCheck

A custom HealthCheck is added to to docker image. It's Java-based to avoid installing curl.

## JDK

### Provider

- openjdk / temurin is not yet ready for alpine on ARM but it's in progress (see https://github.com/adoptium/containers/issues/1#issuecomment-910411264) 

### Size

- Use **jlink** to create custom lightweight JDK, see https://blog.adoptium.net/2021/10/jlink-to-produce-own-runtime/
- **Attention:** jlink on Alpine needs the `binutils` package
- we can try stripping off java modules by changing add-modules command
- Figure out precise list of modules, see https://stackoverflow.com/questions/71276373/jdeps-on-a-directory

```
--add-modules java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.attach,jdk.charsets,jdk.compiler,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.editpad,jdk.hotspot.agent,jdk.httpserver,jdk.internal.ed,jdk.internal.jvmstat,jdk.internal.le,jdk.internal.opt,jdk.internal.vm.ci,jdk.internal.vm.compiler,jdk.internal.vm.compiler.management,jdk.jartool,jdk.javadoc,jdk.jcmd,jdk.jconsole,jdk.jdeps,jdk.jdi,jdk.jdwp.agent,jdk.jfr,jdk.jlink,jdk.jpackage,jdk.jshell,jdk.jsobject,jdk.jstatd,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.random,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.unsupported.desktop,jdk.xml.dom,jdk.zipfs \
```

