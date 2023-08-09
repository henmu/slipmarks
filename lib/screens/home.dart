import 'package:flutter/material.dart';
import 'package:slipmarks/screens/bookmarks.dart';
import 'package:slipmarks/screens/favorites.dart';
import 'package:slipmarks/screens/links.dart';
import 'package:slipmarks/screens/search.dart';
import 'package:slipmarks/screens/login.dart';
import 'package:slipmarks/services/auth_service.dart';
import 'package:slipmarks/elements/mysalomonbottombar.dart';
import 'package:slipmarks/services/messaging_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    Links(),
    Bookmarks(),
    Favorites(),
    Search(),
  ];

  // Instance of MessagingService for handling notifications
  final _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();

    // Initialize MessagingService to handle notifications
    _messagingService.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1f1f1f),
        appBar: AppBar(
          title: const Text(
            'Slipmarks',
            style: TextStyle(
              fontFamily: 'Inter',
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () => _openEndDrawer(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(
                            AuthService.instance.profile?.picture ?? ''),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          backgroundColor: const Color(0xFF1F1F1F),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        endDrawer: Drawer(
          backgroundColor: const Color(0xFF2D2D2D),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 135,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              AuthService.instance.profile?.picture ?? '',
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AuthService.instance.profile?.nickname ?? '',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            AuthService.instance.profile?.name ?? '',
                            style: const TextStyle(
                              color: Color(0xFFB1B1B1),
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                ),
                title: const Text(
                  'Settings',
                ),
                onTap: () {
                  // Handle the onTap event for the Settings list tile
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(),
                ),
                onTap: () async {
                  await AuthService.instance.logout();
                  if (context.mounted) {
                    Navigator.of(context).replace(
                      oldRoute: ModalRoute.of(context)!,
                      newRoute: MaterialPageRoute(
                          builder: (BuildContext context) => const Login()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: MySalomonBottomBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF313131),
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            //Home
            MySalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text('Home'),
              selectedBackgroundColor: const Color(0xFFEDDDFF),
              selectedColor: const Color(0xFF472C82),
            ),
            MySalomonBottomBarItem(
              icon: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              selectedBackgroundColor: const Color(0xFFD0EBEF),
              selectedColor: const Color(0xFF1496AA),
            ),
            MySalomonBottomBarItem(
              icon: const Icon(Icons.star),
              title: const Text('Favorites'),
              selectedBackgroundColor: const Color(0xFFFBEFD3),
              selectedColor: const Color(0xFFEDA600),
            ),
            MySalomonBottomBarItem(
              icon: const Icon(Icons.search),
              title: const Text('Search'),
              selectedBackgroundColor: const Color(0xFFE4FFE4),
              selectedColor: const Color(0xFF1B4721),
            ),
          ],
        ),
      ),
    );
  }

  void _openEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
}
