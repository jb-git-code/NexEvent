import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/channel_model.dart';
import 'package:nexevent/providers/user_provider.dart';
import 'package:nexevent/services/channel_service.dart';
import 'package:nexevent/widgets/channel_card.dart';

class ChannelsPage extends ConsumerStatefulWidget {
  const ChannelsPage({super.key});

  @override
  ConsumerState<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends ConsumerState<ChannelsPage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("channels").snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshots.hasData) {
            return CircularProgressIndicator();
          }
          final docs = snapshots.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final channelData = docs[index].data();
              final channel = ChannelModel.fromMap(channelData);
              final joined = currentUser!.joinedChannels.contains(
                channel.channelId,
              );
              return ChannelCard(
                name: channelData["name"],
                description: channelData["description"],
                icon: channelData["icon"],
                type: channelData["type"],
                memberCount: channelData["memberCount"] ?? 0,
                isMandatory: channelData["isMandatory"] ?? false,
                key: ValueKey(channelData["channelId"]),
                channelId: channelData["channelId"],
                // onJoin: () async {
                //   if (channel.isMandatory) return;

                //   if (joined) {
                //     await ChannelService().leaveChannel(
                //       uid: currentUser.uid,

                //       channelId: channel.channelId,
                //     );
                //   } else {
                //     await ChannelService().joinChannel(
                //       uid: currentUser.uid,

                //       channelId: channel.channelId,
                //     );
                //   }
                // },
              );
            },
          );
        },
      ),
    );
  }
}
