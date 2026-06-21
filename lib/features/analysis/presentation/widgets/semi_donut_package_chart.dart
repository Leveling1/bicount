import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Modèle de données simplifié
class DeviceData {
  final String label;
  final int value;
  final double percentage;
  final Color color;

  DeviceData(this.label, this.value, this.percentage, this.color);
}

class SemiDonutPackageChart extends StatelessWidget {
  const SemiDonutPackageChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Vos données basées sur l'image
    final List<DeviceData> chartData = [
      DeviceData('Monitor', 1341, 76.1, const Color(0xFF3F51B5)),
      DeviceData('Laptop', 217, 13.4, const Color(0xFF03A9F4)),
      DeviceData('Mobile', 124, 6.2, const Color(0xFF00E676)),
      DeviceData('Tablet', 53, 3.4, const Color(0xFFFFB300)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Le Graphique Syncfusion
          SizedBox(
            height: 180, // On réduit la hauteur car c'est un demi-cercle
            child: SfCircularChart(
              margin: EdgeInsets.zero,
              // Le trou au milieu et le texte central
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '1735',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Clicks',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
              series: <CircularSeries>[
                DoughnutSeries<DeviceData, String>(
                  dataSource: chartData,
                  xValueMapper: (DeviceData data, _) => data.label,
                  yValueMapper: (DeviceData data, _) => data.percentage,
                  pointColorMapper: (DeviceData data, _) => data.color,
                  
                  // L'ASTUCE : On transforme le cercle complet en demi-cercle
                  startAngle: 270, // Commence à gauche (en haut)
                  endAngle: 90,    // Finit à droite

                  innerRadius: '80%', // Épaisseur de l'anneau
                  radius: '100%',
                  
                  // Espacement blanc léger entre les segments (comme sur votre image)
                  strokeColor: const Color(0xFF121212), 
                  strokeWidth: 3,
                )
              ],
            ),
          ),

          // Légende personnalisée (Optionnelle si vous voulez garder le style exact de l'image)
          const SizedBox(height: 10),
          ...chartData.map((data) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: data.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(data.label, style: const TextStyle(color: Colors.white)),
                ),
                Text('${data.value}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 10),
                Text('|  ${data.percentage}%', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}