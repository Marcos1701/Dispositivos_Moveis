class Person {
  String name;
  String email;
  String senha;
  bool selected = false;

  Person({required this.name, required this.email, required this.senha});

  void changeName(String newName) {
    name = newName;
  }

  void changeEmail(String newEmail) {
    email = newEmail;
  }

  void changeSenha(String newSenha) {
    senha = newSenha;
  }

  void toggleSelected() {
    selected = !selected;
  }
}
