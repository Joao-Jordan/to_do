import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List _tasksList = [];
  late File file;
  final _taskController = TextEditingController();
  bool _iscomposing = false; //Flag que indica se algum texto foi digitado
  late Map<String, dynamic> _lastTaskRemoved;
  late int _lastTaskRemovedPos;

  @override //Função que reescreve a lista sempre que o app é reaberto
  void initState() {
    super.initState();

    _readTasks().then(
          (tasks) {
        setState(() {
          _tasksList = json.decode(tasks!);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text(
          'TO DO',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
      ),
      backgroundColor: Colors.blueGrey[900],
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: RefreshIndicator(
                backgroundColor: Colors.orange,
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: _tasksList.length, //Quantidade de itens da lista
                  itemBuilder: buildStatusIcons,
                ),
                onRefresh: _refreshTasks,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(
                Radius.circular(40.0),
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, top: 11),
                    height: 40,
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(color: Colors.white),
                      controller: _taskController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration.collapsed(
                          hintText: 'Digite a nova task...',
                          hintStyle:
                          TextStyle(fontSize: 14, color: Colors.white)),
                      onChanged: (text) {
                        setState(
                              () {
                            _iscomposing = text.isNotEmpty;
                          },
                        );
                      },
                      onSubmitted: (text) {
                        _addNewTask();
                        setState(() {
                          resetTaskButton();
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      size: 35,
                      color: _iscomposing ? Colors.orange : Colors.grey,
                    ),
                    onPressed: _iscomposing ? _addNewTask : null),
              ],
            ),
          ),
        ],
      ),
    );
  }

//Função que desativa o botão de confirmar
  Future<void> resetTaskButton() async {
    setState(
          () {
        _iscomposing = false;
      },
    );
  }

//getFile() - Retorna o arquivo com as Tasks feitas pelo usuário
  Future<File?> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return file = File('${directory.path}/tasks.json');
  }

//addNewTask - adiciona o taskController.text na lista taskList
  void _addNewTask() {
    log('$_tasksList');
    setState(
          () {
        if (_taskController.text.isNotEmpty) {
          Map<String, dynamic> newTask = {};
          newTask['title'] = _taskController.text;
          _taskController.text = '';
          newTask['checked'] = false;
          _tasksList.add(newTask);
          _saveTasks();
        }
      },
    );
  }

//saveTasks - Salva as Tasks em um arquivo na memória
  Future<File?> _saveTasks() async {
    String tasks = json.encode(_tasksList);
    final file = await _getFile();
    return file!.writeAsString(tasks);
  }

//readTasks - Lê as Tasks salvas no getFile
  Future<String?> _readTasks() async {
    try {
      final file = await _getFile();
      return file!.readAsString();
    } catch (erro) {
      return null;
    }
  }

//addNewTask - adiciona o taskController.text na lista taskList
  void addNewTask() {
    log('$_tasksList');
    setState(
          () {
        if (_taskController.text.isNotEmpty) {
          Map<String, dynamic> newTask = {};
          newTask['title'] = _taskController.text;
          _taskController.text = '';
          newTask['checked'] = false;
          _tasksList.add(newTask);
          _saveTasks();
        }
      },
    );
  }

  //refreshTasks - Aplica um delay e depois compara pares de Tasks para organizar o código
  Future<void> _refreshTasks() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _tasksList.sort(
            (task_1, task_2) {
          if (task_1['checked'] && !task_2['checked']) {
            return 1;
          } else if (!task_1['checked'] && task_2['checked']) {
            return -1;
          } else {
            return 0;
          }
        },
      );
      _saveTasks();
    });
    return;
  }

//buildItem - Tem como objetivo adicionar na tela os ícones de status da task
  Widget buildStatusIcons(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: const Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        checkColor:
        _tasksList[index]['checked'] ? Colors.white.withOpacity(0.1) : null,
        activeColor: _tasksList[index]['checked']
            ? Colors.white.withOpacity(0.1)
            : null,
        controlAffinity: ListTileControlAffinity.leading,
        side: const BorderSide(color: Colors.orange),
        title: Text(
          _tasksList[index]['title'],
          style: TextStyle(
            color: _tasksList[index]['checked']
                ? Colors.white.withOpacity(0.1)
                : Colors.white,
          ),
        ),
        value: _tasksList[index]['checked'],
        secondary: Icon(
          _tasksList[index]['checked']
              ? Icons.check
              : Icons.watch_later_outlined,
          color: _tasksList[index]['checked']
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.8),
        ),
        onChanged: (done) {
          setState(
                () {
              _tasksList[index]['checked'] = done;
              _saveTasks();
            },
          );
        },
      ),
      onDismissed: (direction) {
        setState(
              () {
            _lastTaskRemoved = Map.from(_tasksList[index]);
            _lastTaskRemovedPos = index;
            _tasksList.removeAt(index);
            _saveTasks();

            final snack = SnackBar(
              content: Text(
                'Tarefa ${_lastTaskRemoved['title']} foi removida',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              action: SnackBarAction(
                label: 'Desfazer',
                textColor: Colors.orange,
                onPressed: () {
                  setState(
                        () {
                      _tasksList.insert(
                        _lastTaskRemovedPos,
                        _lastTaskRemoved,
                      );
                      _saveTasks();
                    },
                  );
                },
              ),
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
          },
        );
      },
    );
  }
}
