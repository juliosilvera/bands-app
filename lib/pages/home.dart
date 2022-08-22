// ignore_for_file: avoid_print

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bandas = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'AC/DC', votes: 3),
    // Band(id: '3', name: 'Iron Maidem', votes: 2),
    // Band(id: '4', name: 'Rata Blanca', votes: 1),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      bandas = (payload as List).map((band) => Band.fromMap(band)).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: addNewBand,
          elevation: 1,
        ),
        appBar: AppBar(
          elevation: 1,
          title: const Text(
            'BandNames',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.Online
                  ? Icon(
                      Icons.signal_cellular_alt,
                      color: Colors.green[600],
                    )
                  : const Icon(
                      Icons.signal_cellular_connected_no_internet_0_bar,
                      color: Colors.red,
                    ),
            )
          ],
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Column(
          children: [
            _showGraph(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, i) => _bandTile(bandas[i]),
                itemCount: bandas.length,
              ),
            ),
          ],
        ));
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketService.emit('del-band', band.toJson());
      },
      background: Container(
        padding: const EdgeInsets.only(left: 8),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name!.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name!),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.emit('vote-band', band.toJson()),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('New band name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                  textColor: Colors.blue,
                  child: const Text('Add'),
                  elevation: 5,
                  onPressed: () => addBandToList(textController.text))
            ],
          );
        });
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.emit('add-band', {'name': name});
    }

    Navigator.of(context).pop();
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    bandas.forEach((element) {
      dataMap.putIfAbsent(element.name!, () => element.votes!.toDouble());
    });
    return SizedBox(
        width: double.infinity, height: 200, child: PieChart(dataMap: dataMap));
  }
}
