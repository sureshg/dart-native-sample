## Dart2Native sample web server app.

 A sample dart web app compile to native executable using [Dart2Native][Dart2Native] tool.

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