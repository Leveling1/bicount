class Memoji {
  final int id;
  final String imagePath;
  final String? name;

  Memoji({required this.id, required this.imagePath, this.name});
}

class MemojiUtils {
  static final List<Memoji> defaultMemojis = [
    Memoji(id: 1, imagePath: 'assets/memoji/memoji_1.png', name: 'Charlène'),
    Memoji(id: 2, imagePath: 'assets/memoji/memoji_2.png', name: 'Jessica'),
    Memoji(id: 3, imagePath: 'assets/memoji/memoji_3.png', name: 'Ruth'),
    Memoji(id: 4, imagePath: 'assets/memoji/memoji_4.png', name: 'Bertrand'),
    Memoji(id: 5, imagePath: 'assets/memoji/memoji_5.png', name: 'Biju'),
    Memoji(id: 6, imagePath: 'assets/memoji/memoji_default.png', name: 'Charles'),
    Memoji(id: 7, imagePath: 'assets/memoji/memoji_7.png', name: 'John'),
  ];

  static Memoji? getMemojiById(int id) {
    return defaultMemojis.firstWhere(
      (m) => m.id == id,
      orElse: () => defaultMemojis.first,
    );
  }

  static List<Memoji> getAllMemojis() => defaultMemojis;
}
