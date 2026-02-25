import 'dart:async';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key}); 

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool _isStart = true;

  String _stopwatchText = '00:00:00';

  final Stopwatch _stopWatch = Stopwatch();

  Timer? _timer;

  final List<String> _historico = [];

  String _horaAtual() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _addHistorico(String mensagem) {
    setState(() {
      _historico.insert(0, mensagem);
    });
  }

  void _startTimer() {
 
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopWatch.isRunning) {
        setState(() {
          _setStopwatchText();
        });
      }
    });
  }

  void _startStopButtonPressed() {
    setState(() {
      if (_stopWatch.isRunning) {
        _stopWatch.stop();
        _timer?.cancel();
        _isStart = true;

        final horas = _stopWatch.elapsed.inSeconds / 3600;

        _addHistorico(
          '⏸ Ponto pausado às ${_horaAtual()} '
          '(${horas.toStringAsFixed(2)}h trabalhadas)',
        );
      } else {
        _stopWatch.start();
        _startTimer();
        _isStart = false;
        if (_stopWatch.elapsed.inSeconds == 0) {
          _addHistorico('▶️ Ponto iniciado às ${_horaAtual()}');
        } else {
          _addHistorico('▶️ Ponto retomado às ${_horaAtual()}');
        }
      }
    });
  }
  void _resetButtonPressed() {

    _stopWatch.stop();
    _timer?.cancel();

    setState(() {
      _stopWatch.reset();
      _setStopwatchText();
      _isStart = true;
      _addHistorico('🔄 Ponto resetado às ${_horaAtual()}');
    });
  }
  void _setStopwatchText() {
    final elapsed = _stopWatch.elapsed;

    _stopwatchText =
        '${elapsed.inHours.toString().padLeft(2, '0')}:'
        '${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Ponto'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                _stopwatchText,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _startStopButtonPressed,
                icon: Icon(
                  _isStart ? Icons.play_arrow : Icons.pause,
                  size: 28,
                ),
                label: Text(_isStart ? 'Iniciar' : 'Pausar'),
              ),
              ElevatedButton.icon(
                onPressed: _resetButtonPressed,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          Expanded(
            flex: 3,
            child: _historico.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum registro de ponto',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _historico.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _historico[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
