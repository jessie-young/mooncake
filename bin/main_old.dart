import 'dart:convert';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'server.dart' as my_server;
import 'package:shelf/shelf_io.dart' as shelf_io;
// import 'create-lambda-function.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
// import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

Handler<AwsALBEvent> createLambdaFunction(shelf.Handler handler) {
  return (Context context, AwsALBEvent request) async {
    Map<String, String> headersMap =
        Map<String, String>.from(request.headers as Map<String, dynamic>);

    // var httpsUri =
    // Uri(scheme: 'https', host: headersMap["Host"], path: request.path);

    // request.path is relative, like /mooncake
    // should parse request.path, strip out the name of the function
    // from the path
    // so if route is /mooncake/mooncake, return just /mooncake
    // ideally want host to include the name of the function
    // workaround: get the function name
    // need to have this custom logic so that you can deploy to cakework
    // because /mooncake/mooncake isn't getting matched to anything,
    // not able to get here. only catching requests
    // List<String> segments = request.path.split('/');
    // String relativePath = '/' + segments.sublist(1).join('/');

    // var httpsUri = Uri(path: request.path);
    Uri uri =
        Uri(scheme: 'https', host: headersMap["Host"], path: request.path);

    print("woot");
    print("got uri");
    print(uri);

    // should strip out the first part of the route

    // is it possible to invoke a shelf handler but only pass relative arguments?

    // Q: should we create different api gateway

    var shelfRequest = shelf.Request(
      request.httpMethod,
      uri,
      headers: headersMap,
      body: request.body == null
          ? null
          : Stream.fromIterable([request.body.codeUnits]),
    );

    var shelfResponse = await handler(shelfRequest);

    var headers = <String, String>{};
    shelfResponse.headers.forEach((name, value) => headers[name] = value);

    var body = await shelfResponse.readAsString();

    // return AwsApiGatewayResponse(
    //   statusCode: shelfResponse.statusCode,
    //   headers: headers,
    //   body: body,
    // );

// final response = AwsApiGatewayResponse.fromJson({
//   "message": "Hello, world!",
//   "data": {
//     "name": "John",
//     "age": 30
//   }
// }, statusCode: 200, headers: {
//   "Content-Type": "application/json"
// });

    // TODO return headers
    return InvocationResult(
        context.requestId,
        AwsApiGatewayResponse(
            body: body,
            isBase64Encoded: false,
            headers: request.headers,
            statusCode: shelfResponse.statusCode));
  };
}

// Q: can i build using docker?
Future<void> main() async {
  // final Handler<AwsApiGatewayEvent> helloApiGateway = (context, event) async {
  //   final response = {"message": "hello ${context.requestId}"};

  //   /// it returns an encoded response to the gateway
  //   return InvocationResult(
  //       context.requestId!, AwsApiGatewayResponse.fromJson(response));
  // };

  // Create a shelf.Handler from the router in the my_server project
  var handler = my_server.handler;

  // Run the server locally to make sure everything works
  // var server = await shelf_io.serve(handler, 'localhost', 8080);
  // print('Server listening on port ${server.port}');

  // Create a Lambda function from the shelf.Handler
  var lambda = createLambdaFunction(handler);

  // Start the Lambda runtime
  // var runtime = Runtime();
  // await runtime.run(lambda);
  Runtime()
    ..registerHandler<AwsALBEvent>("hello.ALB", lambda)
    ..invoke();
}
