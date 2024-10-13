import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Quality Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const HomePage(), const GraphPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Graph',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final String _location = "Sample Location";
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  final Map<String, Map<String, double>> _parameterValues = {
    'Temperature': {'min': 20.0, 'max': 30.0},
    'pH': {'min': 6.0, 'max': 8.0},
    'TDS': {'min': 100.0, 'max': 200.0},
  };

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateParameterValues();
      });
    });
  }

  void _updateParameterValues() {
    final random = Random();
    _parameterValues.forEach((parameter, values) {
      values['min'] =
          (values['min']! + (random.nextDouble() - 0.5)).clamp(0, 100);
      values['max'] =
          (values['max']! + (random.nextDouble() - 0.5)).clamp(0, 100);
      if (values['min']! > values['max']!) {
        final temp = values['min'];
        values['min'] = values['max']!;
        values['max'] = temp!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Quality Monitoring'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[800]!, Colors.blue[400]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 20),
                const Text('Parameter Ranges:',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 10),
                ..._parameterValues.entries.map(
                    (entry) => _buildParameterCard(entry.key, entry.value)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(_location,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(_currentTime.toString(),
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(String parameter, Map<String, double> values) {
    Color cardColor;
    IconData iconData;

    switch (parameter) {
      case 'Temperature':
        cardColor = Colors.orange[300]!;
        iconData = Icons.thermostat;
        break;
      case 'pH':
        cardColor = Colors.green[300]!;
        iconData = Icons.science;
        break;
      case 'TDS':
        cardColor = Colors.purple[300]!;
        iconData = Icons.opacity;
        break;
      default:
        cardColor = Colors.grey[300]!;
        iconData = Icons.help_outline;
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(iconData, size: 30, color: Colors.white),
                const SizedBox(width: 12),
                Text(parameter,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Min: ${values['min']!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                Text('Max: ${values['max']!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GraphPage extends StatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  GraphPageState createState() => GraphPageState();
}

class GraphPageState extends State<GraphPage> {
  final Map<String, List<DataPoint>> _dataPoints = {
    'Temperature': [],
    'pH': [],
    'TDS': [],
  };
  final Map<String, double> _latestValues = {
    'Temperature': 25.0,
    'pH': 7.0,
    'TDS': 150.0,
  };
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startDataSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDataSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateParameter('Temperature', 20, 30, '°C');
        _updateParameter('pH', 6.0, 8.0, '');
        _updateParameter('TDS', 50, 250, 'ppm');
      });
    });
  }

  void _updateParameter(String parameter, double min, double max, String unit) {
    final latestValue = _simulateValue(_latestValues[parameter]!, min, max);
    _latestValues[parameter] = latestValue;
    _dataPoints[parameter]!.add(DataPoint(DateTime.now(), latestValue));
    if (_dataPoints[parameter]!.length > 60) {
      _dataPoints[parameter]!.removeAt(0);
    }
  }

  double _simulateValue(double currentValue, double min, double max) {
    final random = Random();
    final change = (random.nextDouble() - 0.5) * (max - min) * 0.1;
    return (currentValue + change).clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphs'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[800]!, Colors.blue[400]!],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildParameterCard('Temperature', Colors.orange[300]!, '°C',
                '22-28°C (72-82°F) is suitable for many tropical fish.'),
            _buildParameterCard('pH', Colors.green[300]!, '',
                'A pH of 7 is neutral. Most fish thrive in a pH range of 6.5-7.5.'),
            _buildParameterCard('TDS', Colors.purple[300]!, 'ppm',
                'For freshwater aquariums, a TDS range of 100-200 ppm is generally acceptable.'),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(
      String parameter, Color color, String unit, String explanation) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parameter,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800])),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CustomChart(
                  dataPoints: _dataPoints[parameter]!, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              'Current: ${_latestValues[parameter]!.toStringAsFixed(2)} $unit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatus(parameter, _latestValues[parameter]!, unit),
            const SizedBox(height: 8),
            Text(explanation,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(String parameter, double value, String unit) {
    String status;
    Color color;

    switch (parameter) {
      case 'Temperature':
        if (value < 22) {
          status = 'Low';
          color = Colors.blue;
        } else if (value > 28) {
          status = 'High';
          color = Colors.red;
        } else {
          status = 'Good';
          color = Colors.green;
        }
        break;
      case 'pH':
        if (value < 6.5) {
          status = 'Low';
          color = Colors.blue;
        } else if (value > 7.5) {
          status = 'High';
          color = Colors.red;
        } else {
          status = 'Good';
          color = Colors.green;
        }
        break;
      case 'TDS':
        if (value < 100) {
          status = 'Low';
          color = Colors.blue;
        } else if (value > 200) {
          status = 'High';
          color = Colors.red;
        } else {
          status = 'Good';
          color = Colors.green;
        }
        break;
      default:
        status = 'Unknown';
        color = Colors.grey;
    }

    return Text(
      'Status: $status (${value.toStringAsFixed(2)} $unit)',
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}

class DataPoint {
  final DateTime time;
  final double value;

  DataPoint(this.time, this.value);
}

class CustomChart extends StatelessWidget {
  final List<DataPoint> dataPoints;
  final Color color;

  const CustomChart({Key? key, required this.dataPoints, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ChartPainter(dataPoints: dataPoints, color: color),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<DataPoint> dataPoints;
  final Color color;

  ChartPainter({required this.dataPoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final minValue = dataPoints.map((e) => e.value).reduce(min);
    final maxValue = dataPoints.map((e) => e.value).reduce(max);
    final valueRange = maxValue - minValue;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = size.width * i / (dataPoints.length - 1);
      final y = size.height -
          (dataPoints[i].value - minValue) / valueRange * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = size.width * i / (dataPoints.length - 1);
      final y = size.height -
          (dataPoints[i].value - minValue) / valueRange * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
