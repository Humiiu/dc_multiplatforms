import 'dart:math';

const List<String> appGreetings = [
  'Halo',
  'hii :3 (wtff)',
  'Hello',
  'こんにちは',
  '안녕하세요',
  '你好',
  'مرحبا',
  'Sugeng rawuh',
  'Bonjour',
  '¡Hola!',
  'Hallo',
  'Ciao',
];

String getRandomGreeting() {
  final index = Random().nextInt(appGreetings.length);
  return appGreetings[index];
}
