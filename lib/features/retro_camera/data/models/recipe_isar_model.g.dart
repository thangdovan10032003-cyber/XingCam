// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecipeIsarModelCollection on Isar {
  IsarCollection<RecipeIsarModel> get recipeIsarModels => this.collection();
}

const RecipeIsarModelSchema = CollectionSchema(
  name: r'RecipeIsarModel',
  id: 4390978819027101211,
  properties: {
    r'author': PropertySchema(
      id: 0,
      name: r'author',
      type: IsarType.string,
    ),
    r'borderType': PropertySchema(
      id: 1,
      name: r'borderType',
      type: IsarType.byte,
      enumMap: _RecipeIsarModelborderTypeEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'filterId': PropertySchema(
      id: 3,
      name: r'filterId',
      type: IsarType.string,
    ),
    r'grainIntensity': PropertySchema(
      id: 4,
      name: r'grainIntensity',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'showDateStamp': PropertySchema(
      id: 6,
      name: r'showDateStamp',
      type: IsarType.bool,
    )
  },
  estimateSize: _recipeIsarModelEstimateSize,
  serialize: _recipeIsarModelSerialize,
  deserialize: _recipeIsarModelDeserialize,
  deserializeProp: _recipeIsarModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _recipeIsarModelGetId,
  getLinks: _recipeIsarModelGetLinks,
  attach: _recipeIsarModelAttach,
  version: '3.1.0+1',
);

int _recipeIsarModelEstimateSize(
  RecipeIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.author.length * 3;
  bytesCount += 3 + object.filterId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _recipeIsarModelSerialize(
  RecipeIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeByte(offsets[1], object.borderType.index);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.filterId);
  writer.writeDouble(offsets[4], object.grainIntensity);
  writer.writeString(offsets[5], object.name);
  writer.writeBool(offsets[6], object.showDateStamp);
}

RecipeIsarModel _recipeIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecipeIsarModel();
  object.author = reader.readString(offsets[0]);
  object.borderType = _RecipeIsarModelborderTypeValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      FilmBorderType.none;
  object.createdAt = reader.readDateTime(offsets[2]);
  object.filterId = reader.readString(offsets[3]);
  object.grainIntensity = reader.readDouble(offsets[4]);
  object.id = id;
  object.name = reader.readString(offsets[5]);
  object.showDateStamp = reader.readBool(offsets[6]);
  return object;
}

P _recipeIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_RecipeIsarModelborderTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          FilmBorderType.none) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecipeIsarModelborderTypeEnumValueMap = {
  'none': 0,
  'kodakPortra': 1,
  'polaroid': 2,
  'fujiPro': 3,
};
const _RecipeIsarModelborderTypeValueEnumMap = {
  0: FilmBorderType.none,
  1: FilmBorderType.kodakPortra,
  2: FilmBorderType.polaroid,
  3: FilmBorderType.fujiPro,
};

Id _recipeIsarModelGetId(RecipeIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recipeIsarModelGetLinks(RecipeIsarModel object) {
  return [];
}

void _recipeIsarModelAttach(
    IsarCollection<dynamic> col, Id id, RecipeIsarModel object) {
  object.id = id;
}

extension RecipeIsarModelByIndex on IsarCollection<RecipeIsarModel> {
  Future<RecipeIsarModel?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  RecipeIsarModel? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<RecipeIsarModel?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<RecipeIsarModel?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(RecipeIsarModel object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(RecipeIsarModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<RecipeIsarModel> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<RecipeIsarModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension RecipeIsarModelQueryWhereSort
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QWhere> {
  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecipeIsarModelQueryWhere
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QWhereClause> {
  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterWhereClause>
      nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RecipeIsarModelQueryFilter
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QFilterCondition> {
  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'author',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'author',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'author',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'author',
        value: '',
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      borderTypeEqualTo(FilmBorderType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'borderType',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      borderTypeGreaterThan(
    FilmBorderType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'borderType',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      borderTypeLessThan(
    FilmBorderType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'borderType',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      borderTypeBetween(
    FilmBorderType lower,
    FilmBorderType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'borderType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'filterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'filterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'filterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'filterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'filterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'filterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'filterId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'filterId',
        value: '',
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      filterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'filterId',
        value: '',
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      grainIntensityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grainIntensity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      grainIntensityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grainIntensity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      grainIntensityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grainIntensity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      grainIntensityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grainIntensity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterFilterCondition>
      showDateStampEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showDateStamp',
        value: value,
      ));
    });
  }
}

extension RecipeIsarModelQueryObject
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QFilterCondition> {}

extension RecipeIsarModelQueryLinks
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QFilterCondition> {}

extension RecipeIsarModelQuerySortBy
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QSortBy> {
  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy> sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByBorderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borderType', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByBorderTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borderType', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByFilterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterId', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByFilterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterId', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByGrainIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grainIntensity', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByGrainIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grainIntensity', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByShowDateStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateStamp', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      sortByShowDateStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateStamp', Sort.desc);
    });
  }
}

extension RecipeIsarModelQuerySortThenBy
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QSortThenBy> {
  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy> thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByBorderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borderType', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByBorderTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borderType', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByFilterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterId', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByFilterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterId', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByGrainIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grainIntensity', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByGrainIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grainIntensity', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByShowDateStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateStamp', Sort.asc);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QAfterSortBy>
      thenByShowDateStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showDateStamp', Sort.desc);
    });
  }
}

extension RecipeIsarModelQueryWhereDistinct
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct> {
  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct> distinctByAuthor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct>
      distinctByBorderType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borderType');
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct> distinctByFilterId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct>
      distinctByGrainIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grainIntensity');
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecipeIsarModel, RecipeIsarModel, QDistinct>
      distinctByShowDateStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showDateStamp');
    });
  }
}

extension RecipeIsarModelQueryProperty
    on QueryBuilder<RecipeIsarModel, RecipeIsarModel, QQueryProperty> {
  QueryBuilder<RecipeIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecipeIsarModel, String, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<RecipeIsarModel, FilmBorderType, QQueryOperations>
      borderTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borderType');
    });
  }

  QueryBuilder<RecipeIsarModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RecipeIsarModel, String, QQueryOperations> filterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterId');
    });
  }

  QueryBuilder<RecipeIsarModel, double, QQueryOperations>
      grainIntensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grainIntensity');
    });
  }

  QueryBuilder<RecipeIsarModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<RecipeIsarModel, bool, QQueryOperations>
      showDateStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showDateStamp');
    });
  }
}
