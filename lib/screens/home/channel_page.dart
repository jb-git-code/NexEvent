import 'package:flutter/material.dart';

class ChannelsPage extends StatelessWidget {
  const ChannelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Channels",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Join channels to receive updates about events, clubs and college activities.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),

          const SizedBox(height: 25),

          const Text(
            "Official Channels",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _channelCard(
            icon: Icons.campaign,
            color: Colors.blue,
            title: "General",
            subtitle: "Institute wide announcements",
            members: "1200",
            joined: true,
            mandatory: true,
          ),

          _channelCard(
            icon: Icons.event,
            color: Colors.deepPurple,
            title: "Events",
            subtitle: "College events and workshops",
            members: "984",
            joined: false,
          ),

          _channelCard(
            icon: Icons.work,
            color: Colors.teal,
            title: "Placements",
            subtitle: "Placement and internship updates",
            members: "846",
            joined: true,
          ),

          const SizedBox(height: 25),

          const Text(
            "Community Channels",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _channelCard(
            icon: Icons.code,
            color: Colors.orange,
            title: "Coding Club",
            subtitle: "Programming contests & hackathons",
            members: "142",
            joined: true,
          ),

          _channelCard(
            icon: Icons.camera_alt,
            color: Colors.pink,
            title: "Photography Club",
            subtitle: "Campus photography community",
            members: "73",
            joined: false,
          ),

          _channelCard(
            icon: Icons.theater_comedy,
            color: Colors.deepOrange,
            title: "Drama Club",
            subtitle: "Theatre and stage performances",
            members: "81",
            joined: false,
          ),

          _channelCard(
            icon: Icons.sports_esports,
            color: Colors.green,
            title: "Chess Club",
            subtitle: "Weekly chess tournaments",
            members: "67",
            joined: true,
          ),
        ],
      ),
    );
  }

  Widget _channelCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String members,
    required bool joined,
    bool mandatory = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(.12),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(subtitle, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$members Members",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            mandatory
                ? FilledButton(onPressed: null, child: const Text("Mandatory"))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: joined ? Colors.green : color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(joined ? "Joined" : "Join"),
                  ),
          ],
        ),
      ),
    );
  }
}
