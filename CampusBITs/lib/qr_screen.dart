import 'package:flutter/material.dart';
import 'dart:async';

class QRScreen extends StatefulWidget {
  final String menuType;
  final String username;
  final String pickupPoint;

  QRScreen({
    required this.menuType,
    required this.username,
    required this.pickupPoint,
  });

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  static List<Map<String, dynamic>> qrHub = [];
  Timer? timer;
  Duration validityDuration = Duration(hours: 24);
  Duration remainingTime = Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= Duration(seconds: 1);
        } else {
          timer.cancel();
        }
      });
    });
  }

  void saveQr() {
    setState(() {
      qrHub.add({
        'menuType': widget.menuType,
        'username': widget.username,
        'pickupPoint': widget.pickupPoint,
        'validity': DateTime.now().add(validityDuration),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR guardado exitosamente')),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF71679C), Color(0xFF44337A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.menuType.isNotEmpty) ...[
                    Center(
                      child: Column(
                        children: [
                          Image.asset('assets/qr_code.png', height: 200),
                          SizedBox(height: 16),
                          Text(
                            'Menú: ${widget.menuType}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Usuario: ${widget.username}',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Text(
                            'Punto de Retiro: ${widget.pickupPoint}',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: saveQr,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Guardar QR',
                              style: TextStyle(color: Color(0xFF5B3E96)),
                            ),
                          ),
                          Divider(color: Colors.white70, thickness: 1.0),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Text(
                    'QR Guardados:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (qrHub.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: qrHub.length,
                      itemBuilder: (context, index) {
                        final qr = qrHub[index];
                        return Card(
                          color: Colors.white.withOpacity(0.1),
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: Text(
                              'Menú: ${qr['menuType']}',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usuario: ${qr['username']}',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  'Punto de Retiro: ${qr['pickupPoint']}',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  'Validez hasta: ${qr['validity']}',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Center(
                      child: Text(
                        'No hay QR guardados.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
