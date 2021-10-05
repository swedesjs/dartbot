void validateToken(String token) {
  final tokenWorlds = token.split("").map((e) => e.toLowerCase());

  const allowWorldSet = {
    "d",
    "e",
    "f",
    "b",
    "c",
    "a",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9"
  };

  for (final element in tokenWorlds) {
    if (!allowWorldSet.contains(element)) {
      throw Exception("Токен содержит неверные символы!");
    }
  }
}
