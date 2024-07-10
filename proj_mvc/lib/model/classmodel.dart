class ItemModels {
  String name;
  bool check;

  ItemModels({required this.name, required this.check});

  void changeCheck() {
    check = !check;
  }

  void changeName(String newName) {
    name = newName;
  }

  get getName => name;
  get getCheck => check;
}
