import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ManutencaoExtintorPage extends StatefulWidget {
  @override
  _ManutencaoExtintorPageState createState() => _ManutencaoExtintorPageState();
}

class _ManutencaoExtintorPageState extends State<ManutencaoExtintorPage> {
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();
  final TextEditingController manutencaoController = TextEditingController();
  final TextEditingController recargaController = TextEditingController();
  final TextEditingController inspecaoController = TextEditingController();
  final TextEditingController vencimentoController = TextEditingController();

  int? idExtintor;
  bool revisarStatus = false;

  List<Map<String, dynamic>> extintores = [];

  @override
  void initState() {
    super.initState();
    _carregarExtintores();
  }

  Future<void> _carregarExtintores() async {
    final url = Uri.parse('http://localhost:3001/extintores');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          extintores = List<Map<String, dynamic>>.from(data['extintores']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar extintores')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de comunicação com o servidor')),
      );
    }
  }

  Future<void> _selecionarData(BuildContext context, String tipoData) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        switch (tipoData) {
          case 'manutencao':
            manutencaoController.text = formattedDate;
            break;
          case 'recarga':
            recargaController.text = formattedDate;
            break;
          case 'inspecao':
            inspecaoController.text = formattedDate;
            break;
          case 'vencimento':
            vencimentoController.text = formattedDate;
            break;
        }
      });
    }
  }

  Widget _buildDateField(
      {required String label,
      required TextEditingController controller,
      required VoidCallback onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Selecione a data',
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: Text(
          "Histórico de Manutenção",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD9D9D9),
          ),
        ),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Color(0xFFD9D9D9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Selecione o Extintor",
                    border: OutlineInputBorder(),
                  ),
                  value: idExtintor,
                  onChanged: (int? newValue) {
                    setState(() {
                      idExtintor = newValue;
                    });
                  },
                  items: extintores.map((extintor) {
                    return DropdownMenuItem<int>(
                      value: extintor['Patrimonio'],
                      child: Text('Extintor ${extintor['Patrimonio']}'),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                ...[descricaoController, responsavelController, observacoesController]
                    .map((controller) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: controller == descricaoController
                                  ? "Descrição da Manutenção"
                                  : controller == responsavelController
                                      ? "Responsável"
                                      : "Observações",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ))
                    .toList(),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildDateField(
                      label: "Data da Manutenção",
                      controller: manutencaoController,
                      onTap: () => _selecionarData(context, 'manutencao'),
                    ),
                    _buildDateField(
                      label: "Última Recarga",
                      controller: recargaController,
                      onTap: () => _selecionarData(context, 'recarga'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildDateField(
                      label: "Próxima Inspeção",
                      controller: inspecaoController,
                      onTap: () => _selecionarData(context, 'inspecao'),
                    ),
                    _buildDateField(
                      label: "Data de Vencimento",
                      controller: vencimentoController,
                      onTap: () => _selecionarData(context, 'vencimento'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Revisar Status do Extintor?"),
                  value: revisarStatus,
                  onChanged: (bool value) {
                    setState(() {
                      revisarStatus = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Coloque sua função de salvar aqui.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF011689), // Cor de fundo.
                    foregroundColor: Colors.white, // Cor do texto.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0), // Bordas arredondadas.
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Salvar Manutenção",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
