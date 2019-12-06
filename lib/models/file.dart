class MyFile implements Comparable<MyFile> {
  final String path;
  final String name;
  bool selected;
  final extension;

  /// directory or file
  final String type;

  MyFile(
      {this.path, this.name, this.type, this.selected: false, this.extension});

  @override
  int compareTo(other) {
    return type.compareTo(other.type);
  }
}
