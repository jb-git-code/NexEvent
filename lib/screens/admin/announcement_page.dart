import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/announcement_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class AnnouncementPage extends ConsumerStatefulWidget {
  const AnnouncementPage({super.key});

  @override
  ConsumerState<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends ConsumerState<AnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _selectedChannel;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChannel == null) {
      _showSnack('Please select a channel');
      return;
    }

    final user = ref.read(currentUserProvider);
    final id = const Uuid().v4();
    final announcement = AnnouncementModel(
      id: id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      author: user == null ? 'admin' : user.name,
      createdAt: DateTime.now(),
      isPinned: false,
      channelId: _selectedChannel!,
    );

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(id)
          .set(announcement.toMap());
      if (!mounted) return;
      _showSnack('Announcement created');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to create announcement: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'New Announcement',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign_rounded,
                        color: Colors.deepOrange,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Share an update with a channel',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _Card(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. College Closed',
                        prefixIcon: Icon(Icons.title_rounded),
                        border: InputBorder.none,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _contentController,
                      minLines: 3,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        hintText: 'Write the announcement details...',
                        prefixIcon: Icon(Icons.notes_rounded),
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(
                  children: [
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('channels')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          );
                        }

                        final channels = snapshot.data!.docs;
                        final validSelection = channels.any(
                          (doc) => doc.data()['channelId'] == _selectedChannel,
                        );

                        return DropdownButtonFormField<String>(
                          value: validSelection ? _selectedChannel : null,
                          decoration: const InputDecoration(
                            labelText: 'Channel',
                            prefixIcon: Icon(Icons.forum_outlined),
                            border: InputBorder.none,
                          ),
                          hint: const Text('Select a channel'),
                          items: [
                            for (final doc in channels)
                              DropdownMenuItem(
                                value:
                                    doc.data()['channelId'] as String? ??
                                    doc.id,
                                child: Text(
                                  doc.data()['name'] as String? ?? doc.id,
                                ),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedChannel = value),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _createAnnouncement,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Announcement',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
