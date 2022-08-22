// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'ServerStatus: ${socketService.serverStatus}',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            print('enviando mensaje');
            socketService.emit('emitir-mensaje', {
              'nombre': 'Flutter',
              'mensaje': 'Mensaje enviado desde flutter'
            });
          }),
          child: const Icon(Icons.message),
        ));
  }
}
