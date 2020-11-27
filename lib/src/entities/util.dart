///
/// venosyd © 2016-2020
///
/// sergio e. lisan (sels@venosyd.com)
///
library opensyd.dart.providers.entities.util;

import 'package:opensyd_dart/opensyd_dart.dart';

/// retora uma query em forma de mapa de buscas com as
/// IDs que nao precisam retornar
Map<String, dynamic> notThisIDs<T extends SerializableEntity>(List<T> cached) =>
    <String, dynamic>{
      '_id': {
        r'$nin': cached.map((i) => i.id).toList(),
      }
    };

///
/// trata as buscas do mongodb no cache local
/// NAO MEXA NESSA PORRA NEM COM SUA VIDA EM RISCO
///
bool searchByQuery<T extends SerializableEntity>(
  SerializableEntity e,
  Map<String, dynamic> query,
) {
  final maps = <bool>[];

  for (final key in query.keys) {
    final dynamic value = query[key];

    switch (key) {
      case r'$and':
        return !(value as List)
            .map((dynamic v) => searchByQuery(e, v as Map<String, dynamic>))
            .contains(false);

      case r'$or':
        return (value as List)
            .map((dynamic v) => searchByQuery(e, v as Map<String, dynamic>))
            .contains(true);

      default:
        // regex
        if (value is Map && value[0] == r'$regex') {
          final query = value[0][1] as String;
          maps.add(RegExp(
            query.replaceAll('/i', '').replaceAll('/', ''),
            caseSensitive: false,
          ).hasMatch('${e.json[key]}'));
        }

        // in (se o elemento esta dentro uma lista de procurados)
        else if (value is Map && value[0] == r'$in') {
          final inList = value[0][1] as List;
          maps.add(inList.contains(e.json[key]));
        }

        // nin (se o elemento nao esta dentro uma lista de procurados)
        else if (value is Map && value[0] == r'$nin') {
          final inList = value[0][1] as List;
          maps.add(!inList.contains(e.json[key]));
        }

        // comparacao tipica normal
        else {
          maps.add(e.json[key] == value);
        }
    }
  }

  return !maps.contains(false);
}
