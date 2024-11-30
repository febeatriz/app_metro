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
  DateTime? dataManutencao;
  DateTime? ultimaRecarga;
  DateTime? proximaInspecao;
  DateTime? vencimento;
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
      }
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
      setState(() {
        switch (tipoData) {
          case 'manutencao':
            dataManutencao = picked;
            break;
          case 'recarga':
            ultimaRecarga = picked;
            break;
          case 'inspecao':
            proximaInspecao = picked;
            break;
          case 'vencimento':
            vencimento = picked;
            break;
        }
      });
    }
  }

  Future<void> _salvarManutencao() async {
    if (idExtintor == null ||
        descricaoController.text.isEmpty ||
        responsavelController.text.isEmpty ||
        dataManutencao == null ||
        ultimaRecarga == null ||
        proximaInspecao == null ||
        vencimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Todos os campos devem ser preenchidos"),
      ));
      return;
    }

    final url = Uri.parse('http://localhost:3001/salvar_manutencao');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patrimonio': idExtintor,
          'descricao': descricaoController.text,
          'responsavel': responsavelController.text,
          'observacoes': observacoesController.text,
          'data_manutencao': DateFormat('yyyy-MM-dd').format(dataManutencao!),
          'ultima_recarga': DateFormat('yyyy-MM-dd').format(ultimaRecarga!),
          'proxima_inspecao': DateFormat('yyyy-MM-dd').format(proximaInspecao!),
          'data_vencimento': DateFormat('yyyy-MM-dd').format(vencimento!),
          'revisar_status': revisarStatus,
        }));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Manutenção salva com sucesso!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: const Text(
          "Histórico de Manutenção",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF011689),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selecione o Extintor:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: idExtintor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text("Selecione o extintor"),
                items: extintores.map((extintor) {
                  return DropdownMenuItem<int>(
                    value: extintor['Patrimonio'],
                    child: Text('Extintor ${extintor['Patrimonio']}'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    idExtintor = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(descricaoController, "Descrição da Manutenção"),
              const SizedBox(height: 16),
              _buildTextField(responsavelController, "Responsável"),
              const SizedBox(height: 16),
              _buildTextField(observacoesController, "Observações"),
              const SizedBox(height: 16),
              _buildDateButton(
                  "Data de Manutenção", dataManutencao, 'manutencao'),
              const SizedBox(height: 8),
              _buildDateButton("Última Recarga", ultimaRecarga, 'recarga'),
              const SizedBox(height: 8),
              _buildDateButton("Próxima Inspeção", proximaInspecao, 'inspecao'),
              const SizedBox(height: 8),
              _buildDateButton("Vencimento", vencimento, 'vencimento'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Revisar Status do Extintor"),
                value: revisarStatus,
                onChanged: (bool value) {
                  setState(() {
                    revisarStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _salvarManutencao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    "Salvar Manutenção",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, String tipoData) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.grey.shade400),
      ),
      onPressed: () => _selecionarData(context, tipoData),
      child: Text(
        date == null ? label : DateFormat('dd/MM/yyyy').format(date),
      ),
    );
  }
}
