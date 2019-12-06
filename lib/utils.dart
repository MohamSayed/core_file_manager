import 'package:basic_file_manager/notifiers/preferences.dart';

Future<List<dynamic>> sort(List<dynamic> elements, Sorting by,
    {bool reverse: false}) async {
  switch (by) {
    case Sorting.Type:
      if (!reverse)
        return elements..sort((f1, f2) => f1.type.compareTo(f2.type));
      else
        return (elements..sort()).reversed;
      break;
    default:
      return elements..sort();
  }
}
