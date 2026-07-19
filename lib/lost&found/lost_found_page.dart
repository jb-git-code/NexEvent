import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'lost_found_detail_page.dart';
import 'report_item_page.dart';

/// ---------------------------------------------------------------------
/// DATA MODEL — maps to lostAndFound/{id} docs
/// ---------------------------------------------------------------------
class LostFoundItem {
  final String id;
  final String type; // "lost" | "found"
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final String location;
  final String status; // "open" | "resolved"
  final String reporterId;
  final String reporterName;
  final String? contactInfo;
  final DateTime? createdAt;

  const LostFoundItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    this.imageUrl,
    this.contactInfo,
    this.createdAt,
  });

  factory LostFoundItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return LostFoundItem(
      id: doc.id,
      type: data['type'] as String? ?? 'lost',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'other',
      imageUrl: data['imageUrl'] as String?,
      location: data['location'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? 'Unknown',
      contactInfo: data['contactInfo'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'description': description,
        'category': category,
        'imageUrl': imageUrl,
        'location': location,
        'status': status,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'contactInfo': contactInfo,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

const List<String> lostFoundCategories = [
  'electronics',
  'documents',
  'keys',
  'bags',
  'clothing',
  'other',
];

const Map<String, IconData> categoryIcons = {
  'electronics': Icons.devices,
  'documents': Icons.badge,
  'keys': Icons.vpn_key,
  'bags': Icons.backpack,
  'clothing': Icons.checkroom,
  'other': Icons.inventory_2,
};

String categoryLabel(String category) =>
    category.isEmpty ? 'Other' : '${category[0].toUpperCase()}${category.substring(1)}';

/// ---------------------------------------------------------------------
/// REPOSITORY
/// ---------------------------------------------------------------------
class LostFoundRepository {
  final _db = FirebaseFirestore.instance;

  /// type: pass 'lost' or 'found' to filter, null for everything.
  Stream<List<LostFoundItem>> itemsStream({String? type}) {
    Query<Map<String, dynamic>> query = _db.collection('lostAndFound');
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(LostFoundItem.fromDoc).toList(),
        );
  }

  Future<void> createItem(LostFoundItem item) async {
    await _db.collection('lostAndFound').add(item.toMap());
  }

  Future<void> markResolved(String id) async {
    await _db.collection('lostAndFound').doc(id).update({'status': 'resolved'});
  }
}

/// ---------------------------------------------------------------------
/// PAGE — page CONTENT only if you're embedding it in a tab; wrap with
/// your own Scaffold/AppBar if it needs to be a standalone route.
/// ---------------------------------------------------------------------
class LostFoundPage extends StatefulWidget {
  const LostFoundPage({super.key});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> with SingleTickerProviderStateMixin {
  final _repo = LostFoundRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text('Lost & Found', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1F3A5F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1F3A5F),
          tabs: const [Tab(text: 'Lost'), Tab(text: 'Found')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ItemList(stream: _repo.itemsStream(type: 'lost')),
          _ItemList(stream: _repo.itemsStream(type: 'found')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3D5AFE),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Report Item', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReportItemPage()),
          );
        },
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final Stream<List<LostFoundItem>> stream;
  const _ItemList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LostFoundItem>>(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Center(
            child: Text('Nothing here yet', style: TextStyle(color: Colors.grey.shade600)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _ItemCard(item: items[i]),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  final LostFoundItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isResolved = item.status == 'resolved';

    return Opacity(
      opacity: isResolved ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LostFoundDetailPage(item: item)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFECECEC),
                          child: Icon(
                            categoryIcons[item.category] ?? Icons.inventory_2,
                            color: const Color(0xFF1F3A5F),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${categoryLabel(item.category)} • ${item.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    if (isResolved) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Resolved',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}