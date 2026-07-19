import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
class QuickLink {
  final String title;
  final String link;

  const QuickLink({required this.title, required this.link});

  factory QuickLink.fromJson(Map<String, dynamic> json) {
    return QuickLink(
      title: json['title'] as String,
      link: json['link'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'link': link};
}

class QuickLinkSection {
  final String heading;
  final List<QuickLink> links;

  const QuickLinkSection({required this.heading, required this.links});
}

class QuickLinksPage extends StatelessWidget {
  const QuickLinksPage({super.key});

  static const List<QuickLink> _emergencyContacts = [
    QuickLink(title: 'QRT', link: 'tel:1234567890'),
    QuickLink(title: 'Ambulance', link: 'tel:102'),
  ];

  static const List<QuickLinkSection> _sections = [
    QuickLinkSection(
      heading: 'Calendar',
      links: [
        QuickLink(
          title: 'Academic Calendar',
          link:
              'https://iiitbh.ac.in/sites/default/files/2025/Academic_Calendar/index.html',
        ),
        QuickLink(
          title: 'Holiday List',
          link:
              'https://iiitbh.ac.in/sites/default/files/2026/holiday_list/Holidays%20to%20be%20observed%20in%20the%20year%202026.pdf',
        ),
        QuickLink(title: 'Enyugma', link: 'https://enyugma.iiitbh.ac.in/'),
      ],
    ),
    QuickLinkSection(
      heading: 'Academic',
      links: [
        QuickLink(title: 'College Website', link: 'https://www.iiitbh.ac.in/'),
        QuickLink(
          title: 'SAP Portal',
          link: 'https://admission.iiitbh.ac.in/login',
        ),
        QuickLink(title: 'Gymkhana', link: ''),
      ],
    ),
  ];

  Future<void> _openLink(BuildContext context, String link) async {
    final uri = Uri.parse(link);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Quick Links',
          style: GoogleFonts.storyScript(
            fontSize: 24,

            fontWeight: FontWeight.bold,

            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _EmergencyContactCard(
            contacts: _emergencyContacts,
            onTap: (link) => _openLink(context, link),
          ),
          const SizedBox(height: 24),
          for (final section in _sections) ...[
            _SectionHeading(text: section.heading),
            const SizedBox(height: 12),
            _LinksCard(
              links: section.links,
              onTap: (link) => _openLink(context, link),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}


class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F3A5F),
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final List<QuickLink> contacts;
  final void Function(String link) onTap;

  const _EmergencyContactCard({required this.contacts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visible = contacts.take(3).toList();
    final overflow = contacts.length > 3 ? contacts.sublist(3) : <QuickLink>[];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 100, 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE53935), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Contact',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 2,
                runSpacing: 8,
                children: [
                  for (final contact in visible)
                    _Chip(
                      label: contact.title,
                      onTap: () => onTap(contact.link),
                    ),
                  if (overflow.isNotEmpty)
                    _Chip(
                      label: '...',
                      onTap: () => _showOverflowSheet(context, overflow),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showOverflowSheet(BuildContext context, List<QuickLink> extra) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final contact in extra)
              ListTile(
                title: Text(contact.title),
                trailing: const Icon(Icons.call, size: 18),
                onTap: () {
                  Navigator.of(context).pop();
                  onTap(contact.link);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }
}

class _LinksCard extends StatelessWidget {
  final List<QuickLink> links;
  final void Function(String link) onTap;

  const _LinksCard({required this.links, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: const Color(0xFFECECEC),
        child: Column(
          children: [
            for (int i = 0; i < links.length; i++) ...[
              _LinkTile(link: links[i], onTap: () => onTap(links[i].link)),
              if (i != links.length - 1)
                const Divider(height: 1, color: Color(0xFFDDDDDD)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final QuickLink link;
  final VoidCallback onTap;

  const _LinkTile({required this.link, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              link.title,
              style: const TextStyle(fontSize: 17, color: Colors.black87),
            ),
            const Icon(Icons.open_in_new, color: Color(0xFF2962FF), size: 20),
          ],
        ),
      ),
    );
  }
}
