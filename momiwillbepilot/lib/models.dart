export 'models/question.dart';

class OptionItem {
  const OptionItem({required this.id, required this.title});
  final String id;
  final String title;
}

class CardItem {
  const CardItem({required this.id, required this.title, this.options = const []});
  final String id;
  final String title;
  final List<OptionItem> options;
}