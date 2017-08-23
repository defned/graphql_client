// Copyright Thomas Hourlier. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:graphql_client/graphql_client.dart';

import 'queries_examples.dart';

main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

  const endPoint = 'https://api.github.com/graphql';
  var apiToken = Platform.environment['GITHUBQL_TOKEN'];

  final client = new Client();
  final logger = new Logger('GraphQLClient');
  final graphQLClient = new GraphQLClient(
    client,
    logger: logger,
    endPoint: endPoint,
  );

  var query = new LoginQuery();
  var mutation = new AddTestCommentMutation();

  try {
    print('\n\n===================== TEST 1 =====================');

    LoginQuery queryRes = await graphQLClient.execute(
      query,
      variables: {'issueId': 'MDU6SXNzdWUyNDQzNjk1NTI', 'body': 'Test issue 2'},
      headers: {
        'Authorization': 'bearer $apiToken',
      },
    );

    print('=== . ===');
    print(queryRes.viewer.login.value);
    print(queryRes.viewer.bio.value);
    print(queryRes.viewer.bio2.value);

    print('=== .repository ===');
    print(queryRes.viewer.repository.createdAt.value);
    print(queryRes.viewer.repository.description.value);
    print(queryRes.viewer.repository.id.value);
    print(queryRes.viewer.repository.repoName.value);

    print('=== .gist ===');
    print(queryRes.viewer.gist.description.value);

    print('=== .repositories ===');
    queryRes.viewer.repositories.nodes.forEach((n) {
      print(n.repoName.value);
    });
  } on GQLException catch (e) {
    print(e.message);
    print(e.gqlError);
  } finally {
    print('=================== END TEST 1 ===================\n\n');
  }

  try {
    print('\n\n===================== TEST 2 =====================');

    AddTestCommentMutation mutationRes = await graphQLClient.execute(
      mutation,
      variables: {'issueId': 'MDU6SXNzdWUyNDQzNjk1NTI', 'body': 'Test issue '},
      headers: {
        'Authorization': 'bearer $apiToken',
      },
    );

    print('=== .body ===');
    print(mutationRes.addComment.commentEdge.node.body.value);
  } on GQLException catch (e) {
    print(e.message);
    print(e.gqlError);
  } finally {
    print('=================== END TEST 2 ===================\n\n');
  }

  try {
    print('\n\n===================== TEST 3 =====================');

    await graphQLClient.execute(
      mutation,
      variables: {'issueId': 'efwef', 'body': 'Test issue'},
      headers: {
        'Authorization': 'bearer $apiToken',
      },
    );
  } on GQLException catch (e) {
    print(e.message);
    print(e.gqlError);
    print(e.gqlError.first);
  } finally {
    print('=================== END TEST 3 ===================\n\n');
  }
}
