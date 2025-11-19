import 'package:json_annotation/json_annotation.dart';
part 'quote.g.dart';

@JsonSerializable()
class Quote {
  final String text;
  final String? author;
  final String? source;
  final List<String>? categories;
  final int? id;

  const Quote({this.id, required this.text, this.author, this.source, this.categories});

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);

  // static List<Quote> quotes = [
  //   const Quote(
  //       text: 'Lepiej zaliczać się do niektórych, niż do wszystkich.',
  //       author: 'Andrzej Sapkowski',
  //       source: 'Krew Elfów'),
  //   const Quote(
  //       text:
  //           'Czytanie książek to najpiękniejsza zabawa, jaką sobie ludzkość wymyśliła.',
  //       author: 'Wisława Szymborska'),
  //   const Quote(
  //       text:
  //           'Dobrze widzi się tylko sercem. Najważniejsze jest niewidoczne dla oczu.',
  //       author: 'Antoine de Saint-Exupéry',
  //       source: 'Mały Książę'),
  //   const Quote(
  //       text:
  //           'Książki są lustrem: widzisz w nich tylko to co, już masz w sobie.',
  //       author: 'Carlos Ruiz Zafón',
  //       source: 'Cień wiatru'),
  //   const Quote(
  //       text:
  //           'W chwili, kiedy zastanawiasz się czy kogoś kochasz, przestałeś go już kochać na zawsze.',
  //       author: 'Carlos Ruiz Zafón',
  //       source: 'Cień wiatru'),
  //   const Quote(
  //       text:
  //           'Posiedzę tu sobie i na Ciebie poczekam. Kiedy się kogoś kocha, to ten drugi ktoś nigdy nie znika.',
  //       author: 'Alan Alexander Milne',
  //       source: 'Kubuś Puchatek'),
  //   const Quote(
  //       text:
  //           'Miłość nie polega na tym, aby wzajemnie sobie się przyglądać, lecz aby patrzeć razem w tym samym kierunku.',
  //       author: 'Antoine de Saint-Exupéry',
  //       source: 'Mały Książę'),
  //   const Quote(
  //       text:
  //           'Ludzie mają wrodzony talent do wybierania właśnie tego, co dla nich najgorsze.',
  //       author: 'J.K. Rowling',
  //       source: 'Harry Potter i Kamień Filozoficzny'),
  //   const Quote(
  //       text:
  //           'Życie jest jak pudełko czekoladek - nigdy nie wiesz, co ci się trafi.',
  //       author: 'Winston Groom',
  //       source: 'Forrest Gump'),
  // ];
  //
  // static List<String> get getCategories {
  //   Set<String> categories = {};
  //   for (var q in quotes) {
  //     categories.addAll(q.categories ?? []);
  //   }
  //   List<String> list = List.of(categories);
  //   list.sort((a, b) => a.compareTo(b));
  //   return list;
  // }
  //
  // static List<String> get getAuthors {
  //   Set<String> authors = quotes
  //       .where((x) => x.author?.isNotEmpty ?? false)
  //       .map((e) => e.author!)
  //       .toSet();
  //   List<String> list = List.of(authors.toList());
  //   list.sort((a, b) => a.compareTo(b));
  //   return list;
  // }
}
