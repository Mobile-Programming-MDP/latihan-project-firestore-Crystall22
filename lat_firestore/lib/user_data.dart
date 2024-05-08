class UserData{
  String nama;
  int umur;
  String email;

  UserData(this.nama, this.umur, this.email);

  Map<String, dynamic> toJson() {
    return {
      'nama': this.nama,
      'umur': this.umur,
      'email': this.email
    };
  }
}