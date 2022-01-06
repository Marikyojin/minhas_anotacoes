import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/anotacaoHelper.dart';
import 'package:minhas_anotacoes/models/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = [];
  Anotacao? _ultimoRemovido;

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";
    if (anotacao == null) {
      //salvando
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      //atualizando
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color(0xFF9DE1FE),
            title: Text(
              "$textoSalvarAtualizar anotação",
              style: TextStyle(fontSize: 20, color: Color(0xFFAA2E0C)),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Color(0xFFAA2E0C), fontSize: 20),
                    controller: _tituloController,
                    autofocus: true,
                    decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFAA2E0C))),
                        labelText: "Título",
                        labelStyle: TextStyle(color: Color(0xFFAA2E0C)),
                        hintText: "Digite Título"),
                    cursorColor: Color(0xFFAA2E0C),
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Color(0xFFAA2E0C), fontSize: 20),
                    controller: _descricaoController,
                    autofocus: false,
                    decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFAA2E0C))),
                        labelText: "Descrição",
                        labelStyle: TextStyle(color: Color(0xFFAA2E0C)),
                        hintText: "Digite Descrição"),
                    cursorColor: Color(0xFFAA2E0C),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(color: Color(0xFFAA2E0C)),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                  },
                  child: Text(
                    textoSalvarAtualizar,
                    style: TextStyle(color: Color(0xFFAA2E0C)),
                  )),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = [];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = [];
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      //salvar
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int? resultado = await _db.salvarAnotacao(anotacao);
    } else {
      //atualizar
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();

      int? resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    //var formatador = DateFormat("dd/MM/yyyy H:m");
    var formatador = DateFormat.yMMMEd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int? id) async {
    await _db.removerAnotacao(id!);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Minhas anotações",
          style: TextStyle(fontSize: 30, color: Color(0xFFAA2E0C)),
        ),
        backgroundColor: Color(0xFF9DE1FE),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _anotacoes.length,
            itemBuilder: (context, index) {
              final anotacao = _anotacoes[index];

              return Dismissible(
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                  ),
                  onDismissed: (direction) {
                    _ultimoRemovido = anotacao;
                    _removerAnotacao(anotacao.id);

                    final snackbar = SnackBar(
                      content: Text(
                        "Anotação removida!!",
                        style: TextStyle(color: Color(0xFFC5EFF7)),
                      ),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                          textColor: Color(0xFFC5EFF7),
                          label: "Desfazer",
                          onPressed: () {
                            setState(() {
                              _anotacoes.insert(index, _ultimoRemovido!);
                            });
                          }),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  },
                  child: GestureDetector(
                    onTap: () {
                      _exibirTelaCadastro(anotacao: anotacao);
                    },
                    child: Card(
                      color: Color(0xFF9DE1FE),
                      child: ListTile(
                        title: Text(
                          anotacao.titulo,
                          style:
                              TextStyle(color: Color(0xFFAA2E0C), fontSize: 20),
                        ),
                        subtitle: Text(
                          "${anotacao.descricao} - (${_formatarData(anotacao.data)})",
                          style:
                              TextStyle(color: Color(0xFFAA2E0C), fontSize: 15),
                        ),
                        // trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        //   GestureDetector(
                        //     onTap: () {
                        //       _exibirTelaCadastro(anotacao: anotacao);
                        //     },
                        //     child: Padding(
                        //       padding: EdgeInsets.only(right: 16),
                        //       child: Icon(
                        //         Icons.edit,
                        //         color: Colors.green,
                        //       ),
                        //     ),
                        //   ),
                        //   GestureDetector(
                        //     onTap: () {
                        //       _removerAnotacao(anotacao.id);
                        //     },
                        //     child: Padding(
                        //       padding: EdgeInsets.only(right: 0),
                        //       child: Icon(
                        //         Icons.remove_circle,
                        //         color: Colors.red,
                        //       ),
                        //     ),
                        //   ),
                        // ]),
                      ),
                    ),
                  ));
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF9DE1FE),
        foregroundColor: Color(0xFFAA2E0C),
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
