class Equipamento {
  final String id;
  final String nome;
  final String codigo;
  final String? descricao;

  Equipamento({
    required this.id,
    required this.nome,
    required this.codigo,
    this.descricao,
  });

  factory Equipamento.fromMap(Map<String, dynamic> map) {
    return Equipamento(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      codigo: map['codigo'] ?? '',
      descricao: map['descricao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'codigo': codigo,
      'descricao': descricao,
    };
  }
}