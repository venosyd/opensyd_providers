///
/// venosyd © 2016-2020
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.logs;

import 'package:opensyd_dart/opensyd_dart.dart';

import 'entities/_module_.dart';
import 'login.dart';

///
/// @author sergio lisan
/// provedor de logs
///
class LogsProvider {
  ///
  LogsProvider({
    this.namespace,
    bool devmode,
    bool securedev,
    LoginProvider login,
  }) : _entities = EntitiesRepository.build(
          devmode: devmode,
          login: login,
          securedev: securedev,
          authkey: '60cb3d4bdd0e4aa8443be39657054ace'
              '1de7ba9aa1300ef6a5998c020eed3d51',
          db: 'c71310c076c53350de661cbe2ac6e70a',
        );

  ///
  factory LogsProvider.build(
    bool devmode,
    LoginProvider login,
    String namespace, {
    bool securedev = false,
  }) =>
      LogsProvider(
        devmode: devmode,
        securedev: securedev,
        namespace: namespace,
        login: login,
      );

  ///
  final EntitiesRepository _entities;

  ///
  final String namespace;

  /// log de informacao
  Future<void> info({
    String module,
    String user,
    String title,
    String details,
  }) async {
    await _sendLog(
      details: details,
      module: module,
      user: user,
      title: title,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: 1,
    );
  }

  /// log de warning
  Future<void> warning({
    String module,
    String user,
    String title,
    String details,
  }) async {
    await _sendLog(
      details: details,
      module: module,
      user: user,
      title: title,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: 2,
    );
  }

  /// log de erro
  Future<void> error({
    String module,
    String user,
    String title,
    String details,
  }) async {
    await _sendLog(
      details: details,
      module: module,
      user: user,
      title: title,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: 3,
    );
  }

  ///
  Future<void> _sendLog({
    int timestamp,
    int type,
    String module,
    String user,
    String title,
    String details,
  }) async {
    final log = Log()
      ..details = details
      ..module = module
      ..user = user
      ..title = title
      ..namespace = namespace
      ..timestamp = timestamp
      ..type = type;

    await _entities.save<Log>(log);
  }
}
