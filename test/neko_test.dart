import 'package:flutter_test/flutter_test.dart';
import 'package:neko/src/completeness_check.dart';
import 'package:neko/src/locale_generator.dart';
import 'package:yaml_mapper/yaml_mapper.dart';

void main() {
  const String yamlStrEN = """
title: app
section1:
  undersection1:
    key1 : Value
    key2: "great value"
  anotherKey : another value

section2:
  supriseKey: ""Boo!""

end: this is the end
""";

  const String yamlStrDE = """
title: App
section1:
  undersection1:
    key1 : Wert
    key2: "toller Wert"

section2:
  supriseKey: ""Buuh!""

end: das ist das Ende
""";

  group("YAML parsing", () {
    final List<String> yamlLinesEN = yamlStrEN.split('\n');
    final Map<String, dynamic> mapEN =
        parseMap(yamlLinesEN, determineWhitespace(yamlLinesEN));

    test('Parsing test', () {
      expect(mapEN['title'], 'app');
      expect(mapEN['section1']['undersection1']['key1'], 'Value');
      expect(mapEN['section1']['undersection1']['key2'], 'great value');
      expect(mapEN['section1']['anotherKey'], 'another value');
      expect(mapEN['section2']['supriseKey'], '"Boo!"');
    });

    group('Class generation', () {
      final neko =
          LocaleGenerator(mapEN, localeCode: 'en-US', superClass: true);

      final Map<String, dynamic> mapDE = parseMap(yamlStrDE.split('\n'), '  ');
      final localeDE = LocaleGenerator(mapDE, localeCode: 'de-DE');

      test('Superclass', () {
        expect(neko.keys, [
          'title',
          'section1.undersection1.key1',
          'section1.undersection1.key2',
          'section1.anotherKey',
          'section2.supriseKey',
          'end'
        ]);
      });

      test('Uncomplete locale class', () {
        expect(
            findMissingKeys(neko, localeDE).toList(), ['section1.anotherKey']);
      });
    });
  });
}
