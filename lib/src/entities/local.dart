///
/// venosyd © 2016-2020
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.entities.local;

import 'dart:async';
import 'dart:convert' as convert;

import 'package:meta/meta.dart';
import 'package:opensyd_dart/opensyd_dart.dart';

import '_module_.dart';

///
class LocalEntitiesProvider extends EntitiesRepository {
  ///
  LocalEntitiesProvider({
    @required this.baselocal,
    @required InstanceBuilder builder,
    @required CollectionMap collectionmap,
    @required EmptyInstanceGen emptyinstance,
    this.cachedisabled = false,
  }) : super(
          builder: builder,
          collectionmap: collectionmap,
          emptyinstance: emptyinstance,
        );

  ///
  final Database baselocal;

  ///
  final bool cachedisabled;

  ///
  final Map<Type, List<String>> idscache = {};

  //
  // PERSIST
  //

  @override
  Future<T> save<T extends SerializableEntity>(T object, [Type type]) async {
    type = '$T' == '$SerializableEntity' ? type : T;
    object.id ??= '${DateTime.now().microsecondsSinceEpoch}';

    final persisted = await _loadstorage<T>(type);
    persisted[object.id] = object.json;

    baselocal.save('$type', convert.json.encode(persisted));

    if (object != null && !cachedisabled) {
      if (!cache.containsKey(type)) {
        cache[type] = {};
      }

      cache[type][object.id] = object;
    }

    return object;
  }

  @override
  Future<String> delete<T extends SerializableEntity>(
    T object, [
    Type type,
  ]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    final persisted = await _loadstorage<T>(type);
    persisted.remove(object.id);
    baselocal.save('$type', convert.json.encode(persisted));

    cache[type]?.remove(object.id);

    return Responses.SUCCESS;
  }

  //
  // / PERSIST
  //

  //
  // GETTER
  //

  @override
  Future<T> byID<T extends SerializableEntity>(String id, [Type type]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    if (id == null || id.isEmpty) {
      return null;
    }

    if (cache.containsKey(type) && !cachedisabled) {
      final obj = cache[type][id] as T;
      if (obj != null) {
        return obj;
      }
    }

    final persisted = await _loadentities<T>(type);

    final response = persisted.firstWhere(
      (map) => map['id'] == id,
      orElse: () => <String, dynamic>{},
    );

    final obj = response.isNotEmpty ? builder(response) as T : null;

    if (obj != null && !cachedisabled) {
      cache[type] ??= {};
      cache[type][obj.id] = obj;
    }

    return obj;
  }

  @override
  Future<T> by<T extends SerializableEntity>({
    String field,
    dynamic data,
    Type type,
  }) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    if ((field == null || field.isEmpty) || (data == null)) {
      return null;
    }

    if ((cache.containsKey(type)) && !cachedisabled) {
      final obj = cache[type]
          .values
          .firstWhere((e) => e.json[field] == data, orElse: () => null) as T;
      if (obj != null) {
        return obj;
      }
    }

    final persisted = await _loadentities<T>(type);

    final response = persisted.firstWhere(
      (map) => map[field] == data,
      orElse: () => <String, dynamic>{},
    );

    final obj = response.isNotEmpty ? (builder(response) as T) : null;

    if (obj != null && !cachedisabled) {
      cache[type] ??= {};
      cache[type][obj.id] = obj;
    }

    return obj;
  }

  @override
  Future<T> byQuery<T extends SerializableEntity>(Map<String, dynamic> query,
      [Type type]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    if (cache.containsKey(type) && !cachedisabled) {
      List<T> objs = [];

      Iterable<SerializableEntity> it = cache[type].values;

      query.forEach((field, dynamic data) =>
          it = it.where((e) => searchByQuery(e, query)));

      objs = it.toList().cast<T>();

      if (objs.isNotEmpty) {
        return objs[0];
      }
    }

    final persisted = await _loadentities<T>(type);

    final response = persisted.firstWhere(
      (e) => searchByQuery(builder(e), query),
      orElse: () => <String, dynamic>{},
    );

    final obj = response.isNotEmpty ? (builder(response) as T) : null;

    if (obj != null && !cachedisabled) {
      cache[type] ??= {};
      cache[type][obj.id] = obj;
    }

    return obj;
  }

  //
  // / GETTER
  //

  //
  // LISTERS
  //

  @override
  Future<List<T>> all<T extends SerializableEntity>([Type type]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    final list = (await _loadentities<T>(type))
        .map((e) => builder(e))
        .toList()
        .cast<T>();

    if (!cachedisabled) {
      cache[type] ??= {};
      list.forEach((e) => cache[type][e.id] = e);
    }

    return list;
  }

  @override
  Stream<List<T>> allStream<T extends SerializableEntity>({
    Map<String, dynamic> query,
    List<String> ids,
    Type type,
  }) async* {
    type = '$T' == '$SerializableEntity' ? type : T;

    final list = <T>[];

    for (final element in await listByQuery<T>(query, type)) {
      list.add(element);
      yield list;
    }
  }

  @override
  Future<List<String>> allIDs<T extends SerializableEntity>([
    Map<String, dynamic> query,
    Type type,
  ]) async {
    type = '$T' == '$SerializableEntity' ? type : T;
    return (await listByQuery<T>(query, type)).map((e) => e.id).toList();
  }

  @override
  Future<List<T>> listByIDs<T extends SerializableEntity>(List<String> ids,
      [Type type]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    if (ids == null || ids.isEmpty) {
      return [];
    }

    var list = <T>[];

    if (cache.containsKey(type) && !cachedisabled) {
      final cached = cache[type]
          .values
          .where((e) => ids.contains(e.id))
          .toList()
          .cast<T>();

      final notThisIDs = cached.map((c) => c.id).toList();

      final response = (await _loadentities<T>(type))
          .where((e) => ids.contains(e['id']) && !notThisIDs.contains(e['id']))
          .toList();

      list = response.map((e) => builder(e)).toList().cast<T>();

      list.forEach((e) => cache[type][e.id] = e);
      list.addAll(cached);
    }

    // with no cache
    else {
      final response = (await _loadentities<T>(type))
          .where((e) => ids.contains(e['id']))
          .toList();

      list = response.map((e) => builder(e)).toList().cast<T>();

      if (!cachedisabled) {
        cache[type] ??= {};
        list.forEach((e) => cache[type][e.id] = e);
      }
    }

    return list;
  }

  @override
  Future<List<T>> listBy<T extends SerializableEntity>({
    String field,
    dynamic data,
    Type type,
  }) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    if ((field == null || field.isEmpty) || (data == null)) {
      return [];
    }

    var list = <T>[];

    // with cache
    if (cache.containsKey(type) && !cachedisabled) {
      final cached = cache[type]
          .values
          .where((e) => e.json[field] == data)
          .toList()
          .cast<T>();

      final notThisIDs = cached.map((c) => c.id).toList();

      final response = (await _loadentities<T>(type))
          .where(
            (e) => searchByQuery(
              builder(e),
              <String, dynamic>{field: data},
            ),
          )
          .where((e) => !notThisIDs.contains(e['id']))
          .toList();

      list = response.map((e) => builder(e)).toList().cast<T>();

      list.forEach((e) => cache[type][e.id] = e);
      list.addAll(cached);
    }

    // with no cache
    else {
      final response = (await _loadentities<T>(type))
          .where(
            (e) => searchByQuery(
              builder(e),
              <String, dynamic>{field: data},
            ),
          )
          .toList();

      list = response.map((e) => builder(e)).toList().cast<T>();

      if (!cachedisabled) {
        cache[type] ??= {};
        list.forEach((e) => cache[type][e.id] = e);
      }
    }

    return list;
  }

  @override
  Future<List<T>> listByQuery<T extends SerializableEntity>(
    Map<String, dynamic> query, [
    Type type,
  ]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    if (query == null || query.isEmpty) {
      return await all<T>(type);
    }

    var list = <T>[];

    // with cache
    if (cache.containsKey(type) && !cachedisabled) {
      Iterable<SerializableEntity> it = cache[type].values;

      query.forEach((field, dynamic data) =>
          it = it.where((e) => searchByQuery(e, query)));

      final cached = it.toList().cast<T>();
      final notThisIDs = cached.map((c) => c.id).toList();

      final response = (await _loadentities<T>(type))
          .where((e) => searchByQuery(builder(e), query))
          .where((e) => !notThisIDs.contains(e['id']))
          .toList();

      list = response.map((e) => builder(e)).toList().cast<T>();

      list.forEach((e) => cache[type][e.id] = e);
      list.addAll(cached);
    }

    // with no cache
    else {
      final response = (await _loadentities<T>(type))
          .where((e) => searchByQuery(builder(e), query))
          .toList();

      list = response.map((e) => builder(e)).toList().cast<T>();

      if (!cachedisabled) {
        cache[type] ??= {};
        list.forEach((e) => cache[type][e.id] = e);
      }
    }

    return list;
  }

  //
  // / LISTERS
  //

  //
  // PRIVATE SUPPORT FUNCTIONS
  //

  ///
  Future<Map<String, dynamic>> _loadstorage<T extends SerializableEntity>([
    Type type,
  ]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    var data = await baselocal.retrieve('$type');
    data = data == null || data.isEmpty ? '{}' : data;

    return convert.json.decode(data) as Map<String, dynamic>;
  }

  ///
  Future<List<Map<String, dynamic>>>
      _loadentities<T extends SerializableEntity>([Type type]) async {
    type = '$T' == '$SerializableEntity' ? type : T;

    final persisted = await _loadstorage<T>(type);
    return persisted.values.cast<Map<String, dynamic>>().toList();
  }
}
