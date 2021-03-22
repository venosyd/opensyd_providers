///
/// venosyd © 2016-2021
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.entities.nonpersistent;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:opensyd_dart/opensyd_dart.dart';

import '_module_.dart';

///
class NonPersistentEntitiesProvider extends EntitiesRepository {
  ///
  NonPersistentEntitiesProvider({
    @required InstanceBuilder builder,
    @required CollectionMap collectionmap,
    @required EmptyInstanceGen emptyinstance,
  }) : super(
          builder: builder,
          collectionmap: collectionmap,
          emptyinstance: emptyinstance,
        );

  //
  // PERSIST
  //

  @override
  Future<T> save<T extends OpensydEntity>(T object, [Type type]) async {
    object.id ??= '${DateTime.now().microsecondsSinceEpoch}';

    if (object != null) {
      if (!cache.containsKey(T)) {
        cache[T] = {};
      }
      cache[T][object.id] = object;
    }

    return object;
  }

  @override
  Future<String> delete<T extends OpensydEntity>(
    T object, [
    Type type,
  ]) async {
    cache[T]?.remove(object.id);
    return 'SUCCESS';
  }

  //
  // / PERSIST
  //

  //
  // GETTER
  //

  @override
  Future<T> byID<T extends OpensydEntity>(String id, [Type type]) async {
    if (id == null || id.isEmpty) {
      return null;
    }

    if (cache.containsKey(T)) {
      final obj = cache[T][id] as T;
      if (obj != null) {
        return obj;
      }
    }

    return null;
  }

  @override
  Future<T> by<T extends OpensydEntity>({
    String field,
    dynamic data,
    Type type,
  }) async {
    if ((field == null || field.isEmpty) || (data == null)) {
      return null;
    }

    if (cache.containsKey(T)) {
      final obj = cache[T]
          .values
          .firstWhere((e) => e.json[field] == data, orElse: () => null) as T;
      if (obj != null) {
        return obj;
      }
    }

    return null;
  }

  @override
  Future<T> byQuery<T extends OpensydEntity>(
    Map<String, dynamic> query, [
    Type type,
  ]) async {
    if (cache.containsKey(T)) {
      List<T> objs = [];

      Iterable<OpensydEntity> it = cache[T].values;

      query.forEach((field, dynamic data) =>
          it = it.where((e) => searchByQuery(e, query)));

      objs = it.toList().cast<T>();

      if (objs.isNotEmpty) {
        return objs[0];
      }
    }

    return null;
  }

  //
  // / GETTER
  //

  //
  // LISTERS
  //

  @override
  Future<List<T>> all<T extends OpensydEntity>([Type type]) async =>
      cache[T]?.values?.toList()?.cast<T>() ?? [];

  @override
  Stream<List<T>> allStream<T extends OpensydEntity>({
    Map<String, dynamic> query,
    List<String> ids,
    Type type,
  }) async* {
    final list = <T>[];

    for (final element in await listByQuery<T>(query, type)) {
      list.add(element);
      yield list;
    }
  }

  @override
  Future<List<String>> allIDs<T extends OpensydEntity>([
    Map<String, dynamic> query,
    Type type,
  ]) async =>
      (await listByQuery<T>(query, type)).map((e) => e.id).toList();

  @override
  Future<List<T>> listByIDs<T extends OpensydEntity>(
    List<String> ids, [
    Type type,
  ]) async {
    if (ids == null || ids.isEmpty) {
      return [];
    }

    List<T> list = [];

    if (cache.containsKey(T)) {
      list =
          cache[T].values.where((e) => ids.contains(e.id)).toList().cast<T>();
    }

    list.sort((i, j) => i.id.compareTo(j.id));
    return list;
  }

  @override
  Future<List<T>> listBy<T extends OpensydEntity>({
    String field,
    dynamic data,
    Type type,
  }) async {
    if ((field == null || field.isEmpty) || (data == null)) {
      return [];
    }

    List<T> list = [];

    if (cache.containsKey(T)) {
      list = cache[T]
          .values
          .where((e) => e.json[field] == data)
          .toList()
          .cast<T>();
    }

    list.sort((i, j) => i.id.compareTo(j.id));
    return list;
  }

  @override
  Future<List<T>> listByQuery<T extends OpensydEntity>(
    Map<String, dynamic> query, [
    Type type,
  ]) async {
    if (query == null || query.isEmpty) {
      return await all<T>(type);
    }

    List<T> list = [];

    if (cache.containsKey(T)) {
      Iterable<OpensydEntity> it = cache[T].values;

      query.forEach((field, dynamic data) =>
          it = it.where((e) => searchByQuery(e, query)));

      list = it.toList().cast<T>();
    }

    list.sort((i, j) => i.id.compareTo(j.id));
    return list;
  }

  //
  // / LISTERS
  //
}
