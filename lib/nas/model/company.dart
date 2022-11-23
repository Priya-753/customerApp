class Company {
  final int id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(id: json['id'] as int, name: json['name'] as String);
  }

  static Company? getCompany(List<Company> companies, int id) {
    Company? company;
    List.generate(companies.length, (i) {
      if (companies[i].id == id) {
        company = companies[i];
      }
    });
    return company;
  }

}
