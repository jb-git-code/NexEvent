// import 'package:flutter/material.dart';
// import 'home_feed.dart';
// import 'discover.dart';
// import 'create_content_hub.dart';
// import 'clubs_organizations.dart';
// import 'student_profile.dart';

// class CampusScaffold extends StatelessWidget {
//   final Widget body;
//   final String title;
//   final int activeIndex;
//   final Widget? floatingActionButton;

//   const CampusScaffold({
//     super.key,
//     required this.body,
//     this.title = 'UniHub',
//     required this.activeIndex,
//     this.floatingActionButton,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded),
//           onPressed: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Menu drawer opened.')),
//             );
//           },
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: Theme.of(context).colorScheme.primary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Notifications opened.')),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.home_work_rounded),
//             tooltip: 'Back to Hub',
//             onPressed: () {
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//           ),
//         ],
//       ),
//       body: body,
//       floatingActionButton: floatingActionButton,
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 10,
//               offset: const Offset(0, -4),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: activeIndex,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Theme.of(context).colorScheme.primary,
//           unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           unselectedLabelStyle: const TextStyle(fontSize: 12),
//           onTap: (index) {
//             if (index == activeIndex) return;
//             Widget target;
//             switch (index) {
            
//             }
//             Navigator.pushReplacement(
//               context,
//               PageRouteBuilder(
//                 pageBuilder: (context, animation1, animation2) => target,
//                 transitionDuration: Duration.zero,
//                 reverseTransitionDuration: Duration.zero,
//               ),
//             );
//           },
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.explore_outlined),
//               activeIcon: Icon(Icons.explore),
//               label: 'Discover',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.add_circle_outline_rounded),
//               activeIcon: Icon(Icons.add_circle),
//               label: 'Create',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.group_outlined),
//               activeIcon: Icon(Icons.group),
//               label: 'Clubs',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline_rounded),
//               activeIcon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
