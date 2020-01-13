## Dart2Native sample web server app.

 A sample dart web app compile to native executable using [Dart2Native][Dart2Native] tool.

[![GitHub Workflow Status][ShieldIO-Badge]][github-action]


#### Generate X509 Cert

```bash
$ openssl req -newkey rsa:4096 \
    -new -nodes -x509 \
    -days 3650 \
    -out cert.pem \
    -keyout key.pem \
    -subj "/C=US/ST=California/L=San Jose/O=Suresh/OU=Dev/CN=localhost"
```

#### Build & Run

```bash
$ dart2native bin/main.dart -DdefaultPort=8445 -o test-server 
$ ./test-server
```


[Dart2Native]: https://dart.dev/tools/dart2native
[github-action]: https://github.com/sureshg/dart-native-sample/actions
[Github-Actions-Badge]: https://github.com/sureshg/dart-native-sample/workflows/Dart%20CI/badge.svg?branch=master
[ShieldIO-Badge]: https://img.shields.io/github/workflow/status/sureshg/dart-native-sample/Dart%20CI/master?label=Dart%20CI&style=for-the-badge