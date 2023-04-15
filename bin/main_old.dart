import 'dart:convert';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'server.dart' as my_server;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'create-lambda-function.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

Handler<AwsALBEvent> createLambdaFunction(shelf.Handler handler) {
  return (Context context, AwsALBEvent request) async {
    var shelfRequest = shelf.Request(
      request.httpMethod!, // is the ! unsafe?
      Uri.parse(request.path!),
      headers: Map<String, String>.from(
          request.headers as Map<String, dynamic>), // is this valid?
      body: request.body == null
          ? null
          : Stream.fromIterable([request.body!.codeUnits]),
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

    // TODO return headers
    return InvocationResult(
        context.requestId!, AwsALBResponse.fromString(body));
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
