import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'lost_found_page.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  String _type = 'lost';
  String _category = lostFoundCategories.first;
  File? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('lostAndFound')
            .child('${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg');
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final item = LostFoundItem(
        id: '', // ignored by toMap/add
        type: _type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        imageUrl: imageUrl,
        location: _locationController.text.trim(),
        status: 'open',
        reporterId: user.uid,
        reporterName: user.displayName ?? 'Unknown',
        contactInfo: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      );

      await LostFoundRepository().createItem(item);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Report Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TypeToggle(selected: _type, onChanged: (t) => setState(() => _type = t)),
            const SizedBox(height: 20),
            _ImagePickerBox(image: _pickedImage, onTap: _pickImage),
            const SizedBox(height: 20),
            _FieldLabel('Title'),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('e.g. Black wallet'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel('Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration('Describe the item, any identifying details...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel('Category'),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _inputDecoration(null),
              items: [
                for (final c in lostFoundCategories)
                  DropdownMenuItem(value: c, child: Text(categoryLabel(c))),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Location'),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration('e.g. H-12 Mess, Lecture Hall Complex'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel('Contact info (optional)'),
            TextFormField(
              controller: _contactController,
              decoration: _inputDecoration('Phone or email'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Report', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ToggleButton(label: 'Lost', value: 'lost', selected: selected, onChanged: onChanged)),
        const SizedBox(width: 10),
        Expanded(child: _ToggleButton(label: 'Found', value: 'found', selected: selected, onChanged: onChanged)),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onChanged;

  const _ToggleButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _ImagePickerBox({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        clipBehavior: Clip.antiAlias,
        child: image != null
            ? Image.file(image!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500, size: 32),
                  const SizedBox(height: 8),
                  Text('Add a photo (optional)', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
      ),
    );
  }
}