import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SpeedTestApp());
}

class SpeedTestApp extends StatelessWidget {
  const SpeedTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF818CF8),
        ),
      ),
      home: const SpeedTestScreen(),
    );
  }
}

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  bool _isTesting = false;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  int _ping = 0;
  String _status = "Tugmani bosing va testni boshlang";

  final String downloadUrl = "https://speed.hetzner.de/10MB.bin";
  final String uploadUrl = "https://httpbin.org/post";

  Future<void> _runSpeedTest() async {
    setState(() {
      _isTesting = true;
      _downloadSpeed = 0.0;
      _uploadSpeed = 0.0;
      _ping = 0;
      _status = "Ping o'lchanmoqda...";
    });

    try {
      final stopwatch = Stopwatch()..start();
      final pingResponse = await http.get(Uri.parse("https://www.google.com")).timeout(const Duration(seconds: 5));
      stopwatch.stop();
      if (pingResponse.statusCode == 200) {
        setState(() {
          _ping = stopwatch.elapsedMilliseconds;
        });
      }

      setState(() {
        _status = "Yuklab olish (Download) tezligi o'lchanmoqda...";
      });

      final dlStopwatch = Stopwatch()..start();
      final dlResponse = await http.get(Uri.parse(downloadUrl)).timeout(const Duration(seconds: 20));
      dlStopwatch.stop();

      if (dlResponse.statusCode == 200) {
        final bytesCount = dlResponse.bodyBytes.length;
        final seconds = dlStopwatch.elapsedMilliseconds / 1000.0;
        final bitsCount = bytesCount * 8;
        final mbps = (bitsCount / seconds) / 1000000.0;

        setState(() {
          _downloadSpeed = double.parse(mbps.toStringAsFixed(2));
        });
      }

      setState(() {
        _status = "Yuklash (Upload) tezligi o'lchanmoqda...";
      });

      final Uint8List dummyData = Uint8List(2 * 1024 * 1024);
      final ulStopwatch = Stopwatch()..start();
      final ulResponse = await http.post(
        Uri.parse(uploadUrl),
        body: dummyData,
      ).timeout(const Duration(seconds: 20));
      ulStopwatch.stop();

      if (ulResponse.statusCode == 200) {
        final bytesCount = dummyData.length;
        final seconds = ulStopwatch.elapsedMilliseconds / 1000.0;
        final bitsCount = bytesCount * 8;
        final mbps = (bitsCount / seconds) / 1000000.0;

        setState(() {
          _uploadSpeed = double.parse(mbps.toStringAsFixed(2));
        });
      }

      setState(() {
        _status = "Test muvaffaqiyatli yakunlandi!";
      });
    } catch (e) {
      setState(() {
        _status = "Xatolik yuz berdi. Internet aloqasini tekshiring.";
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Speed Test', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isTesting
                            ? [const Color(0xFF38BDF8), const Color(0xFF818CF8)]
                            : [Colors.grey.shade800, Colors.grey.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isTesting
                              ? const Color(0xFF38BDF8).withOpacity(0.4)
                              : Colors.black26,
                          blurRadius: 25,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _downloadSpeed.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Mbps Download',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricCard("Ping", "$_ping ms", Icons.network_ping, Colors.amber),
                  _buildMetricCard("Download", "$_downloadSpeed Mbps", Icons.file_download_outlined, const Color(0xFF38BDF8)),
                  _buildMetricCard("Upload", "$_uploadSpeed Mbps", Icons.file_upload_outlined, const Color(0xFF818CF8)),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isTesting ? null : _runSpeedTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: _isTesting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'TESTNI BOSHLASH',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
