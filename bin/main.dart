import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:dart_native_sample/utils.dart' as cert_util;
import 'package:http/io_client.dart';
import 'package:path/path.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:rsocket/payload.dart';
import 'package:rsocket/rsocket_connector.dart';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addFlag('shutdown',
      abbr: 's',
      help: 'Shutdown the server after serving first request',
      defaultsTo: false);

  parser.addOption('url',
      abbr: 'l', help: 'Take screenshot of the URL', defaultsTo: '');

  parser.addFlag('help', abbr: 'h', help: 'Show this help and exit',
      callback: (help) {
    if (help) {
      printEnv();
      print(parser.usage);
      exit(0);
    }
  });

  var argResults = parser.parse(args);
  var url = argResults['url'].toString();
  var shutdown = argResults['shutdown'].toString().toLowerCase() == 'true';

  if (url.isNotEmpty) {
    var uri = Uri.tryParse(url);
    if (uri != null) {
      await takeScreenShotOf(uri);
    } else {
      print('Invalid uri provided: $uri');
    }
  }

  if (!shutdown) {
    print('Registering the Signal handlers...');
    registerSignalHandler();
  }

  // rsocket client test
  await rsocketDemo();

  // Read the certs and key
  String cert, key;
  try {
    print('Looking for certs in the current directory ${current}');
    cert = await File('cert.pem').readAsString(encoding: utf8);
    key = await File('key.pem').readAsString(encoding: utf8);
  } catch (e, s) {
    //stderr.writeln(s);
    print(e);
    print('Using the default certs!');
    cert = cert_util.cert;
    key = cert_util.key;
  }

  // Start HTTPS server and handle requests.
  var securityContext = SecurityContext()
    ..useCertificateChainBytes(utf8.encode(cert))
    ..usePrivateKeyBytes(utf8.encode(key))
    ..setTrustedCertificatesBytes(utf8.encode(cert));

  var port = const int.fromEnvironment('defaultPort', defaultValue: 8443);
  var server = await HttpServer.bindSecure(
      InternetAddress.anyIPv4, port, securityContext);

  var uri = Uri.parse('https://localhost:${server.port}/');
  print('Listening on $uri...');

  handleRequests(server);

  // Send HTTPS request using [HttpClient]
  print('Sending ${uri.scheme} request : ${uri.path}');
  var iohClient = HttpClient(context: securityContext)
    ..connectionTimeout = Duration(seconds: 5)
    ..idleTimeout = Duration(seconds: 5)
    ..userAgent = 'Dart2NativeApp'
    ..badCertificateCallback = (cert, host, port) {
      print(
          'Got some cert error. CN: ${cert.subject}, Host: $host, Port: $port');
      return true;
    };

  // Multiplatform client.
  var client = IOClient(iohClient);
  print('Multiplatform http client: $client');

  var req = await iohClient.getUrl(uri)
    ..headers.contentType = ContentType.json
    ..followRedirects = true;
  var res = await req.close();

  // Response JSON from server
  printCertDetails(res);
  var resString = await utf8.decoder.bind(res).join();
  var resJson = json.decode(resString) as Map<String, dynamic>;
  print('Response JSON  : $resJson');

  if (shutdown) {
    print('Shutting down the server...');
    await server.close(force: true);
  }
}

/// Print OS and runtime details
void printEnv() {
  print('''
Runtime Env:
 OS: ${Platform.operatingSystem}: ${Platform.operatingSystemVersion}
 Dart: ${Platform.version}
''');
}

/// Print the server cert details
void printCertDetails(HttpClientResponse res) {
  print('Server Cert Subject: ${res.certificate.subject}');
  var certData = X509Utils.x509CertificateFromPem(res.certificate.pem);
  print('Server Cert SAN: ${certData.subjectAlternativNames}');
}

/// Take the screenshot of a url using puppeteer.
void takeScreenShotOf(Uri uri) async {
  print('Getting the screenshot of ${uri}');
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // Setup the dimensions and user-agent of a particular phone
  await page.emulate(puppeteer.devices.pixel2XL);
  await page.goto(uri.toString(), wait: Until.networkIdle);
  // Take a screenshot of the page
  var screenshot = await page.screenshot();
  // Save it to a file
  await File('${uri.host}.png').writeAsBytes(screenshot);
  await browser.close();
}

/// rsocket websocket transport demo.
void rsocketDemo() async {
  var rsocketUrl = 'wss://rsocket-demo.herokuapp.com/rsocket';
  print('Connecting to rsocket url: $rsocketUrl');
  var client = await RSocketConnector.create().connect(rsocketUrl);

  print('Start streaming the data...');
  var stream = await client.requestStream(Payload.fromText('', 'hello'));

  var i = 1;
  await stream.take(25).forEach((e) {
    print('${i++} - ${e.getDataUtf8()}');
  });

  print('Closing the rsocket connection.');
  client.close();
}

/// Handle all Http requests
void handleRequests(HttpServer server) async {
  await for (HttpRequest req in server) {
    print('Got ${req.method} request: ${req.uri.path}');
    var res = {
      'path': req.uri.toString(),
      'message': 'Hello Dart2Native',
      'time': DateTime.now().toIso8601String()
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
