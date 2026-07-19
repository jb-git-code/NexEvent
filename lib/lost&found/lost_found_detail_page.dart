import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'lost_found_page.dart';

class LostFoundDetailPage extends StatelessWidget {
  final LostFoundItem item;
  const LostFoundDetailPage({super.key, required this.item});

  Future<void> contactReporter() async {}

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = uid != null && uid == item.reporterId;
    final isResolved = item.status == 'resolved';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                item.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                categoryIcons[item.category] ?? Icons.inventory_2,
                size: 60,
                color: const Color(0xFF1F3A5F),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Badge(
                text: item.type == 'lost' ? 'LOST' : 'FOUND',
                color: item.type == 'lost'
                    ? Colors.red.shade400
                    : Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              _Badge(
                text: categoryLabel(item.category),
                color: const Color(0xFF1F3A5F),
              ),
              if (isResolved) ...[
                const SizedBox(width: 8),
                _Badge(text: 'RESOLVED', color: Colors.grey.shade600),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: item.location,
          ),
          if (item.createdAt != null)
            _InfoRow(
              icon: Icons.access_time,
              label: 'Reported',
              value: _formatDate(item.createdAt!),
            ),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Reported by',
            value: item.reporterName,
          ),
          if (item.contactInfo != null && item.contactInfo!.isNotEmpty)
            _InfoRow(
              icon: Icons.contact_phone_outlined,
              label: 'Contact',
              value: item.contactInfo!,
            ),
          const SizedBox(height: 24),
          if (isOwner && !isResolved)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await LostFoundRepository().markResolved(item.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F3A5F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Mark as Resolved',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          // else if (!isResolved && item.contactInfo != null && item.contactInfo!.isNotEmpty)
          //   SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton.icon(
          //       onPressed: () {
          //         // TODO: launch tel:/mailto: with item.contactInfo, or
          //         // open in-app chat once that exists.
          //       },
          //       icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          //       label: const Text('Contact Reporter', style: TextStyle(color: Colors.white, fontSize: 16)),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: const Color(0xFF3D5AFE),
          //         padding: const EdgeInsets.symmetric(vertical: 16),
          //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
