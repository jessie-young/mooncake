import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';

void main() async {
  /// This demo's handling an ALB request.
  final Handler<AwsALBEvent> helloALB = (context, event) async {
    final response = '''
<html>
<header><title>My Lambda Function</title></header>
<body>
Success! I created my first Dart Lambda function.
</body>
</html>
''';

    /// Returns the response to the ALB.
    return InvocationResult(
        context.requestId, AwsALBResponse.fromString(response));
  };

  /// The Runtime is a singleton.
  /// You can define the handlers as you wish.
  Runtime()
    ..registerHandler<AwsALBEvent>("hello.ALB", helloALB)
    ..invoke();
}
