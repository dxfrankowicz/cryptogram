// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
      id: (json['id'] as num?)?.toInt(),
      text: json['text'] as String,
      author: json['author'] as String?,
      source: json['source'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'text': instance.text,
      'author': instance.author,
      'source': instance.source,
      'categories': instance.categories,
      'id': instance.id,
    };
