///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.entities;

import 'package:meta/meta.dart';
import 'package:opensyd_dart/opensyd_dart.dart';

import '../login.dart';
import '../repository.dart';
import '../util/_module_.dart';
import 'local.dart';
import 'nonpersistent.dart';
import 'remote.dart';

export '_deprecated_.dart';
export 'local.dart';
export 'nonpersistent.dart';
export 'remote.dart';
export 'util.dart';

///
/// provedor de entidades abstrato
///
abstract class EntitiesRepository extends Entities {
  ///
  EntitiesRepository({
    @required InstanceBuilder builder,
    @required CollectionMap collectionmap,
    @required EmptyInstanceGen emptyinstance,
  }) : super(
          builder: builder,
          collectionmap: collectionmap,
          emptyinstance: emptyinstance,
        );

  /// escolhe qual provedor de entitidades correto para facilitar
  /// na hora de programar
  factory EntitiesRepository.build({
    String db,
    String authkey,
    bool isLocal = false,
    bool isNonPersistent = false,
    bool devmode = false,
    bool securedev = false,
    Database localdb,
    LoginProvider login,
    RepositoryProvider repository,
    InstanceBuilder fromjson = opensydEntitiesMap,
    EmptyInstanceGen emptyinstance = opensydEmptyInstance,
    CollectionMap collectionmap = opensydCollectionMap,
  }) {
    if (isNonPersistent) {
      return _buildNonPersistentEntities(
        fromjson,
        emptyinstance,
        collectionmap,
      );
    }
    //
    else if (isLocal) {
      return _buildLocalEntities(
        localdb,
        fromjson,
        emptyinstance,
        collectionmap,
      );
    }
    //
    else {
      repository ??= RepositoryProvider(
        repositoryHost(devmode, securedev),
        login,
      );

      return _buildRepositoryEntities(
        devmode: devmode,
        securedev: securedev,
        login: login,
        repository: repository,
        authkey: authkey,
        database: db,
        builder: fromjson,
        emptyinstance: emptyinstance,
        collectionmap: collectionmap,
      );
    }
  }

  /// para testes
  static EntitiesRepository _buildLocalEntities(
    Database database,
    InstanceBuilder fromjson,
    EmptyInstanceGen emptyinstance,
    CollectionMap collectionmap,
  ) =>
      LocalEntitiesProvider(
        baselocal: database,
        builder: fromjson,
        emptyinstance: emptyinstance,
        collectionmap: collectionmap,
      );

  /// para testes
  static EntitiesRepository _buildNonPersistentEntities(
    InstanceBuilder fromjson,
    EmptyInstanceGen emptyinstance,
    CollectionMap collectionmap,
  ) =>
      NonPersistentEntitiesProvider(
        builder: fromjson,
        collectionmap: collectionmap,
        emptyinstance: emptyinstance,
      );

  /// instanciador de entities repositories
  static EntitiesRepository _buildRepositoryEntities({
    bool devmode,
    bool securedev,
    LoginProvider login,
    RepositoryProvider repository,
    String authkey,
    String database,
    InstanceBuilder builder,
    EmptyInstanceGen emptyinstance,
    CollectionMap collectionmap,
  }) =>
      RemoteEntitiesProvider(
        authkey: authkey,
        database: database,
        login: login,
        mongodb: repository,
        builder: builder,
        collectionmap: collectionmap,
        emptyinstance: emptyinstance,
      );
}
