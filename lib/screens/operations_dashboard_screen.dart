// lib/screens/operations_dashboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../widgets/curved_header.dart';
import '../widgets/action_button.dart';

/// Same backend + routes as other dashboards
const String _apiBaseUrl = "http://192.168.1.8";

class OperationsDashboardScreen extends StatelessWidget {
  const OperationsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CurvedHeader(
          title: 'OPERATIONS DASHBOARD',
          subtitle: 'Nodes management and residents location',
          icon: Icons.analytics_outlined,
          compact: true,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _MapSection(),
                SizedBox(height: 24),
                _NodesManagementSection(),
                SizedBox(height: 24),
                _ResidentsSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ────────────────────────────────────────────────────────────────
   MAP SECTION  (now dynamic: shows ALL nodes as markers)
──────────────────────────────────────────────────────────────── */

class _MapSection extends StatefulWidget {
  const _MapSection();

  @override
  State<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<_MapSection> {
  bool _loading = true;
  String? _error;
  List<NodeLocation> _nodes = [];

  @override
  void initState() {
    super.initState();
    _fetchNodes();
  }

  Future<void> _fetchNodes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse("$_apiBaseUrl/node/locations");
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        throw Exception("Node API returned ${res.statusCode}");
      }

      final decoded = json.decode(res.body) as Map<String, dynamic>;
      final list = (decoded["nodes"] as List<dynamic>)
          .map((e) => NodeLocation.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _nodes = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Match admin dashboard outer section cards
    final Color outerColor =
        isDark ? const Color(0xFF181818) : const Color(0xFFFFFDEB);

    return Card(
      color: outerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildMap(),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load node locations\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_nodes.isEmpty) {
      return const Center(child: Text('No nodes available'));
    }

    // Center map on first node (you can change logic later if needed)
    final first = _nodes.first;
    final center = LatLng(first.lat, first.lng);

    final markers = _nodes
        .map(
          (n) => Marker(
            point: LatLng(n.lat, n.lng),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              size: 36,
              color: Colors.red,
            ),
          ),
        )
        .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.floodwatch_desktop',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

/* ────────────────────────────────────────────────────────────────
   NODES MANAGEMENT
   (outer card like admin sections, inner like MetricCard)
──────────────────────────────────────────────────────────────── */

class _NodesManagementSection extends StatelessWidget {
  const _NodesManagementSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Outer card: same idea as AdminDashboard _SectionContainer
    final Color outerColor =
        isDark ? const Color(0xFF181818) : const Color(0xFFFFFDEB);

    // Inner mini-card where "Total No. of Nodes" sits:
    // use the same tone as MetricCard background.
    final Color innerCardColor =
        isDark ? const Color(0xFF252525) : const Color(0xFFE4EEBC);

    return Card(
      color: outerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nodes Management',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Total nodes card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: innerCardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total No. of Nodes:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '2',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // EDIT / REGISTER nodes using ActionButton
                const ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'EDIT NODES',
                  onTap: _noop,
                ),
                const ActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'REGISTER NODES',
                  onTap: _noop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // simple placeholder callback
  static void _noop() {}
}

/* ────────────────────────────────────────────────────────────────
   RESIDENTS SECTION — PAGINATED + SEARCH + CUSTOM FOOTER
   (outer card = section style, inner table area styled by theme)
──────────────────────────────────────────────────────────────── */

class _ResidentsSection extends StatefulWidget {
  const _ResidentsSection();

  @override
  State<_ResidentsSection> createState() => _ResidentsSectionState();
}

class _ResidentsSectionState extends State<_ResidentsSection> {
  late ResidentsTableSource _tableSource;

  int _rowsPerPage = 4;
  int _currentPage = 1;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    final dummy = [
      ResidentRowModel(
        name: "Harold R. Lucero",
        lastLocation: "14.739246233688732, 121.03832437190388",
        dateTime: "2025-11-18 15:58:14",
      ),
      ResidentRowModel(
        name: "Mary Anne Dizon",
        lastLocation: "14.739100, 121.038500",
        dateTime: "2025-11-18 15:40:22",
      ),
      ResidentRowModel(
        name: "Juan Dela Cruz",
        lastLocation: "14.738900, 121.038200",
        dateTime: "2025-11-18 15:22:01",
      ),
      ResidentRowModel(
        name: "Andrea Pascual",
        lastLocation: "14.738700, 121.038100",
        dateTime: "2025-11-18 15:05:44",
      ),
    ];

    _tableSource = ResidentsTableSource(dummy);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalRows = _tableSource.rowCount;
    final totalPages = (totalRows / _rowsPerPage).ceil().clamp(1, 999);

    // Outer card like admin sections
    final Color outerColor =
        isDark ? const Color(0xFF181818) : const Color(0xFFFFFDEB);

    // Search bar fill: mimic MetricCard interior tone
    final Color searchFill =
        isDark ? const Color(0xFF252525) : Colors.white;

    return Card(
      color: outerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Residents Location',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 16),

            /* ───────────── SEARCH BAR ───────────── */
            TextField(
              decoration: InputDecoration(
                hintText: "Search by Name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: searchFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                  _tableSource.applyFilter(_searchQuery);
                  _currentPage = 1;
                });
              },
            ),

            const SizedBox(height: 20),

            /* ───────── PAGINATED TABLE WITHOUT DEFAULT FOOTER ───────── */
            SizedBox(
              height: 390,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final colWidth = constraints.maxWidth / 3;

                  return PaginatedDataTable(
                    header: const Text("Registered Users"),
                    showCheckboxColumn: false,
                    rowsPerPage: _rowsPerPage,
                    availableRowsPerPage: const [4],
                    columnSpacing: 0,
                    onPageChanged: (startRowIndex) {
                      setState(() {
                        _currentPage =
                            (startRowIndex / _rowsPerPage).floor() + 1;
                      });
                    },
                    columns: [
                      DataColumn(
                        label: SizedBox(
                          width: colWidth,
                          child: const Text(
                            "Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: colWidth,
                          child: const Text(
                            "Last Location",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: colWidth,
                          child: const Text(
                            "Date/Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    source: _tableSource,
                  );
                },
              ),
            ),

            /* ───────────── CUSTOM FOOTER BELOW TABLE ───────────── */
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "$_currentPage of $totalPages",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ────────────────────────────────────────────────────────────────
   MODEL + DATASOURCE
──────────────────────────────────────────────────────────────── */

class ResidentRowModel {
  final String name;
  final String lastLocation;
  final String dateTime;

  ResidentRowModel({
    required this.name,
    required this.lastLocation,
    required this.dateTime,
  });
}

class ResidentsTableSource extends DataTableSource {
  List<ResidentRowModel> _allRows;
  List<ResidentRowModel> _filteredRows;

  ResidentsTableSource(this._allRows)
      : _filteredRows = List.from(_allRows);

  /* SEARCH */
  void applyFilter(String query) {
    if (query.isEmpty) {
      _filteredRows = List.from(_allRows);
    } else {
      _filteredRows = _allRows
          .where((row) => row.name.toLowerCase().contains(query))
          .toList();
    }
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _filteredRows.length) return null;

    final r = _filteredRows[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(r.name)),
        DataCell(Text(r.lastLocation)),
        DataCell(Text(r.dateTime)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _filteredRows.length;

  @override
  int get selectedRowCount => 0;
}

/* ────────────────────────────────────────────────────────────────
   NODE MODEL (for map section)
──────────────────────────────────────────────────────────────── */

class NodeLocation {
  final int nodeId;
  final String nodeName;
  final int siteId;
  final String siteName;
  final double lat;
  final double lng;

  NodeLocation({
    required this.nodeId,
    required this.nodeName,
    required this.siteId,
    required this.siteName,
    required this.lat,
    required this.lng,
  });

  factory NodeLocation.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);

    return NodeLocation(
      nodeId: json['node_id'] ?? 0,
      nodeName: json['node_name'] ?? '',
      siteId: json['site_id'] ?? 0,
      siteName: json['site_name'] ?? '',
      lat: _d(json['latitude']),
      lng: _d(json['longitude']),
    );
  }
}
