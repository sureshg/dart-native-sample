import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:resource/resource.dart';

main() async {
  registerSignalHandler();

  // Read the certs and key
  String cert, key;
  try {
    cert =
        await const Resource("lib/certs/cert.pem").readAsString(encoding: utf8);
    key =
        await const Resource("lib/certs/key.pem").readAsString(encoding: utf8);
  } catch (e, s) {
    //stderr.writeln(s);
    print(e);
    exit(-1);
  }

  // Start HTTPS server and handle requests.
  var securityContext = SecurityContext()
    ..useCertificateChainBytes(utf8.encode(cert))
    ..usePrivateKeyBytes(utf8.encode(key))
    ..setTrustedCertificatesBytes(utf8.encode(cert));

  var port = const int.fromEnvironment("defaultPort", defaultValue: 8443);
  HttpServer server = await HttpServer.bindSecure(
      InternetAddress.anyIPv4, port, securityContext);

  var uri = Uri.parse('https://${server.address.host}:${server.port}/');
  print('Listening on $uri...');

  handleRequests(server);

  // Send HTTPS request using [HttpClient]
  print('Sending ${uri.scheme} request : ${uri.path}');
  var client = HttpClient(context: securityContext)
    ..userAgent = "Dart2NativeApp";
  var req = await client.getUrl(uri)
    ..headers.contentType = ContentType.json
    ..followRedirects = true;
  var res = await req.close();

  // Response JSON from server
  printCertDetails(res);
  String resString = await utf8.decoder.bind(res).join();
  var resJson = json.decode(resString) as Map<String, dynamic>;
  print('Response JSON  : $resJson');
}

/// Print the server cert details
void printCertDetails(HttpClientResponse res) {
  print('Server Cert Subject: ${res.certificate.subject}');
  var sanIPs = X509Utils.x509CertificateFromPem(res.certificate.pem)
      .subjectAlternativNames
      .map((n) => Uint8List.fromList(n.codeUnits).join("."))
      .toList();
  print('Server Cert SAN: ${sanIPs}');
}

/// Handle all Http requests
void handleRequests(HttpServer server) async {
  await for (HttpRequest req in server) {
    print('Got ${req.method} request: ${req.uri.path}');
    var res = {
      "path": req.uri.toString(),
      "message": "Hello Dart2Native",
      "time": DateTime.now().toIso8601String()
    };

    req.response
      ..headers.contentType = ContentType.json
      ..statusCode = HttpStatus.ok
      ..writeln(json.encode(res));
    await req.response.close();
  }
}

/// Register an interrupt handler for the server.
///
/// See [ProcessSignal.sigint] for more details.
void registerSignalHandler() async {
  await for (ProcessSignal signal in ProcessSignal.sigint.watch()) {
    print(' Got ${signal} signal');
    print('Existing the process with pid: $pid ...');
    sleep(Duration(seconds: 1));
    exit(0);
  }
}
