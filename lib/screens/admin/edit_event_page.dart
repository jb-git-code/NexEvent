import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexevent/models/event_model.dart';
import 'package:nexevent/services/firestore_service.dart';
import 'package:nexevent/services/storage_services.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key, required this.docId, required this.map});

  final String docId;
  final Map<String, dynamic> map;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _ChannelOption {
  final String channelId;
  final String name;
  const _ChannelOption({required this.channelId, required this.name});
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;

  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _newImageUrl;
  String? _existingImageUrl;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  String? _selectedChannelId;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    final map = widget.map;
    _nameController = TextEditingController(text: map['name'] as String? ?? '');
    _descriptionController = TextEditingController(
      text: map['description'] as String? ?? '',
    );
    _venueController = TextEditingController(
      text: map['venue'] as String? ?? '',
    );
    _selectedChannelId = map['channelId'] as String?;
    _existingImageUrl = map['imageUrl'] as String?;
    _isCancelled = map['isCancelled'] as bool? ?? false;
    _startDateTime = (map['eventDate'] as Timestamp?)?.toDate();
    _endDateTime = (map['endDate'] as Timestamp?)?.toDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _isUploadingImage = true;
    });

    try {
      final url = await StorageService().uploadPoster(
        _imageFile!,
        widget.docId,
      );
      if (!mounted) return;
      setState(() => _newImageUrl = url);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Image upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: initial ?? DateTime.now(),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDateTime(initial: _startDateTime);
    if (picked != null) setState(() => _startDateTime = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await _pickDateTime(initial: _endDateTime);
    if (picked != null) setState(() => _endDateTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedChannelId == null) {
      _showSnack('Please select a channel');
      return;
    }
    if (_startDateTime == null || _endDateTime == null) {
      _showSnack('Please pick both start and end date/time');
      return;
    }
    if (_endDateTime!.isBefore(_startDateTime!)) {
      _showSnack('End date/time must be after the start');
      return;
    }
    if (_isUploadingImage) {
      _showSnack('Please wait for the image to finish uploading');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FirestoreService().updateEvent(
        EventModel(
          eventId: widget.docId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          venue: _venueController.text.trim(),
          channelId: _selectedChannelId!,
          imageUrl: _newImageUrl ?? _existingImageUrl ?? '',
          eventDate: _startDateTime!,
          endDate: _endDateTime!,
          isCancelled: _isCancelled,
          regisCount: widget.map['regisCount'] as int? ?? 0,
        ),
        widget.docId,
      );
      if (!mounted) return;
      _showSnack('Event updated successfully');
      Navigator.pop(context);
    } catch (e) {
      _showSnack('Failed to update event: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDateTime(DateTime dt) {
    final date = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$date, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Update Event',
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PosterPicker(
                  imageFile: _imageFile,
                  existingImageUrl: _existingImageUrl,
                  isUploading: _isUploadingImage,
                  primaryColor: primaryColor,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 24),

                _SectionCard(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Enter event name',
                        labelText: 'Event Name',
                        prefixIcon: Icon(Icons.title_rounded),
                        border: InputBorder.none,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Enter event details and info',
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _venueController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Enter event location',
                        labelText: 'Venue',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: InputBorder.none,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionCard(
                  children: [
                    _ChannelDropdown(
                      selectedChannelId: _selectedChannelId,
                      onChanged: (id) =>
                          setState(() => _selectedChannelId = id),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionCard(
                  children: [
                    _DateTimeRow(
                      icon: Icons.event_available_outlined,
                      label: 'Start',
                      value: _startDateTime != null
                          ? _formatDateTime(_startDateTime!)
                          : 'Not set',
                      onTap: _pickStartDate,
                    ),
                    const Divider(height: 24),
                    _DateTimeRow(
                      icon: Icons.event_busy_outlined,
                      label: 'End',
                      value: _endDateTime != null
                          ? _formatDateTime(_endDateTime!)
                          : 'Not set',
                      onTap: _pickEndDate,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _SectionCard(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: _isCancelled
                              ? Colors.red
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mark as Cancelled',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isCancelled
                                    ? 'This event is cancelled'
                                    : 'Event is active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isCancelled,
                          activeColor: Colors.red,
                          onChanged: (v) => setState(() => _isCancelled = v),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shadowColor: primaryColor.withValues(alpha: 0.3),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
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
                          'Update Event',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _PosterPicker extends StatelessWidget {
  final File? imageFile;
  final String? existingImageUrl;
  final bool isUploading;
  final Color primaryColor;
  final VoidCallback onTap;

  const _PosterPicker({
    required this.imageFile,
    required this.existingImageUrl,
    required this.isUploading,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(imageFile!, fit: BoxFit.cover),
              )
            else if (existingImageUrl != null && existingImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(existingImageUrl!, fit: BoxFit.cover),
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 44,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Event Poster',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            // Always show a "change photo" hint over the existing/new image
            if (imageFile != null ||
                (existingImageUrl != null && existingImageUrl!.isNotEmpty))
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Change',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            if (isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

class _ChannelDropdown extends StatelessWidget {
  final String? selectedChannelId;
  final ValueChanged<String?> onChanged;

  const _ChannelDropdown({
    required this.selectedChannelId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('channels')
          .orderBy('name')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }

        final options = snap.data!.docs.map((doc) {
          final data = doc.data();
          return _ChannelOption(
            channelId: data['channelId'] as String? ?? doc.id,
            name: data['name'] as String? ?? doc.id,
          );
        }).toList();

        return DropdownButtonFormField<String>(
          value: options.any((o) => o.channelId == selectedChannelId)
              ? selectedChannelId
              : null,
          decoration: const InputDecoration(
            labelText: 'Channel',
            prefixIcon: Icon(Icons.forum_outlined),
            border: InputBorder.none,
          ),
          hint: const Text('Select a channel'),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option.channelId,
                child: Text(option.name),
              ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}
