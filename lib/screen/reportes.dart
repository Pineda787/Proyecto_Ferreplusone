import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String _nombreUsuario = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> ganancias = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        final data = doc.data();
        final rol = data?['rol'];
        if (rol != 'admin') {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          _nombreUsuario = data?['nombre'] ?? 'Admin';
          await _generarGananciasPorMes();
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _generarGananciasPorMes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('facturas')
          .get();
      final Map<String, double> gananciaPorMes = {};
      final rand = Random();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('fecha') &&
            data['fecha'] != null &&
            data.containsKey('total')) {
          final fecha = data['fecha'] is Timestamp
              ? (data['fecha'] as Timestamp).toDate()
              : DateTime.tryParse(data['fecha'].toString()) ?? DateTime.now();

          final totalRaw = data['total'];
          final total = totalRaw is num
              ? totalRaw.toDouble()
              : double.tryParse(totalRaw.toString()) ?? 0.0;

          if (total <= 0) continue;

          final mes = DateFormat('MMM yyyy', 'es_ES').format(fecha);

          //  Simulación de ganancia: entre 30% y 60% del total
          final porcentaje = 0.3 + rand.nextDouble() * 0.3;
          final ganancia = total * porcentaje;

          gananciaPorMes[mes] = (gananciaPorMes[mes] ?? 0) + ganancia;
        }
      }

      ganancias =
          gananciaPorMes.entries
              .map((e) => {'mes': e.key, 'total': e.value})
              .toList()
            ..sort((a, b) {
              final fa = DateFormat(
                'MMM yyyy',
                'es_ES',
              ).parse(a['mes'].toString());
              final fb = DateFormat(
                'MMM yyyy',
                'es_ES',
              ).parse(b['mes'].toString());
              return fa.compareTo(fb);
            });
    } catch (e) {
      print('Error generando ganancias: $e');
      ganancias = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalGanancia = ganancias.fold(
      0.0,
      (suma, item) => suma + item['total'],
    );

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: screenWidth * 0.25,
            color: Colors.orange,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.network('https://i.imgur.com/CK31nrT.png', height: 280),
                const SizedBox(height: 20),
                const Text(
                  'MENU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildMenuButton(context, 'INVENTARIO', '/inventarioAdmin'),
                _buildMenuButton(context, 'REPORTES', '/reportes'),
                _buildMenuButton(context, 'CONFIGURACIÓN', '/configuracion'),
                _buildMenuButton(context, 'VOLVER AL MENÚ', '/menuAdmin'),
                const Spacer(),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _nombreUsuario,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    child: Image.network(
                      'https://i.imgur.com/qxRSDQR.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.6)),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GANANCIA ESTIMADA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total Ganancia Simulada: L. ${totalGanancia.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ganancias.isEmpty
                          ? const Text(
                              'Sin datos para graficar.',
                              style: TextStyle(color: Colors.white),
                            )
                          : SizedBox(height: 300, child: _buildLineChart()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < ganancias.length) {
                  return Text(
                    ganancias[index]['mes'],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: ganancias.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value['total']);
            }).toList(),
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 4,
            dotData: FlDotData(show: true),
          ),
        ],
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () => Navigator.pushReplacementNamed(context, route),
        child: Text(
          label,
          style: const TextStyle(color: Colors.orange, fontSize: 16),
        ),
      ),
    );
  }
}
