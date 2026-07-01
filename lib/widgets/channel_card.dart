import 'package:flutter/material.dart';
import 'package:nexevent/models/channel_model.dart';

class ChannelCard extends StatelessWidget {
  final ChannelModel channel;
  final bool isJoined;
  final VoidCallback onPressed;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.isJoined,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOfficial = channel.type == "official";

    Color accentColor =
        isOfficial ? Colors.blue : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: accentColor.withOpacity(0.12),
            child: Text(
              channel.icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  channel.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  channel.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),

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
                      "${channel.memberCount} Members",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          channel.isMandatory
              ? FilledButton(
                  onPressed: null,
                  child: const Text("Mandatory"),
                )
              : FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isJoined
                        ? Colors.green
                        : accentColor,
                  ),
                  onPressed: onPressed,
                  child: Text(
                    isJoined ? "Joined" : "Join",
                  ),
                ),
        ],
      ),
    );
  }
}