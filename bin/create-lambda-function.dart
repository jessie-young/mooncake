import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:aws_lambda_dart_runtime/runtime/context.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

// Future<AwsApiGatewayEvent> createLambdaFunction(
// // Future<APIGatewayProxyHandler> createLambdaFunction(
//     shelf.Handler handler) async {
//   // Convert the Shelf handler to an AWS Lambda handler
//   return (APIGatewayProxyRequest request) async {
//     // Create a Shelf request from the API Gateway proxy request
//     var shelfRequest = shelf.Request(
//       request.httpMethod,
//       Uri.parse(request.path),
//       headers: request.headers,
//       body: request.body == null
//           ? null
//           : Stream.fromIterable([request.body.codeUnits]),
//     );

//     // Handle the request using the Shelf handler
//     var shelfResponse = await handler(shelfRequest);

//     // Convert the Shelf response to an API Gateway proxy response
//     var headers = <String, String>{};
//     shelfResponse.headers.forEach((name, value) => headers[name] = value);
//     return APIGatewayProxyResponse(
//       statusCode: shelfResponse.statusCode,
//       headers: headers,
//       body: shelfResponse.readAsStringSync(),
//     );
//   };
// }

// typedef AwsApiGatewayHandler = Future<AwsApiGatewayResponse> Function(
//     AwsApiGatewayEvent request);

typedef AwsApiGatewayHandler = Future<AwsApiGatewayResponse> Function(
    AwsApiGatewayEvent request);

AwsApiGatewayHandler createLambdaFunction(shelf.Handler handler) {
  return (AwsApiGatewayEvent request) async {
    var shelfRequest = shelf.Request(
      request.httpMethod!, // is the ! unsafe?
      Uri.parse(request.path!),
      headers:
          Map<String, String>.from(request.headers as Map), // is this valid?
      body: request.body == null
          ? null
          : Stream.fromIterable([request.body!.codeUnits]),
    );

    var shelfResponse = await handler(shelfRequest);

    var headers = <String, String>{};
    shelfResponse.headers.forEach((name, value) => headers[name] = value);

    var body = await shelfResponse.readAsString();

    return AwsApiGatewayResponse(
      statusCode: shelfResponse.statusCode,
      headers: headers,
      body: body,
    );
  };
}
