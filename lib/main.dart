import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slipmarks/services/auth_service.dart';
import 'home.dart';
import 'login.dart';
import 'bookmarks.dart';
import 'favorites.dart';
import 'search.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F1F1F),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) {
          return const LoginPage();
        },
        '/home': (BuildContext context) {
          return const MyHomePage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const Home(),
    const Bookmarks(),
    const Favorites(),
    const Search(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f1f1f),
      appBar: AppBar(
        title: const Text(
          'Slipmarks',
          style: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.blue, width: 4),
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image:
                    NetworkImage(AuthService.instance.profile?.picture ?? ''),
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1F1F1F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: CustomNavigationBarItem(
              iconData: Icons.home,
              label: 'Home',
              itemIndex: 0,
              isSelected: currentIndex == 0,
              onTap: onTap,
            ),
          ),
          Flexible(
            child: CustomNavigationBarItem(
              iconData: Icons.bookmark,
              label: 'Bookmarks',
              itemIndex: 1,
              isSelected: currentIndex == 1,
              onTap: onTap,
            ),
          ),
          Flexible(
            child: CustomNavigationBarItem(
              iconData: Icons.favorite,
              label: 'Favorites',
              itemIndex: 2,
              isSelected: currentIndex == 2,
              onTap: onTap,
            ),
          ),
          Flexible(
            child: CustomNavigationBarItem(
              iconData: Icons.search,
              label: 'Search',
              itemIndex: 3,
              isSelected: currentIndex == 3,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavigationBarItem extends StatelessWidget {
  final IconData iconData;
  final String label;
  final int itemIndex;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const CustomNavigationBarItem({
    super.key,
    required this.iconData,
    required this.label,
    required this.itemIndex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(itemIndex),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(12, isSelected ? 12 : 0, 12, 12),
            decoration: BoxDecoration(
              color: isSelected ? _getBoxColor(itemIndex) : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  color: isSelected ? _getIconColor(itemIndex) : Colors.white,
                  size: 17.43,
                ),
                if (isSelected) const SizedBox(width: 7),
                if (isSelected)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: _getIconColor(itemIndex),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBoxColor(int itemIndex) {
    switch (itemIndex) {
      case 0:
        return const Color(0xFFEDDDFF); // Home box color
      case 1:
        return const Color(0xFFD0EBEF); // Bookmarks box color
      case 2:
        return const Color(0xFFFBEFD3); // Favorites box color
      case 3:
        return const Color(0xFFE4FFE4); // Search box color
      default:
        return Colors.transparent;
    }
  }

  Color _getIconColor(int itemIndex) {
    switch (itemIndex) {
      case 0:
        return const Color(0xFF472C82); // Home icon and text color
      case 1:
        return const Color(0xFF1496AA); // Bookmarks icon and text color
      case 2:
        return const Color(0xFFEDA600); // Favorites icon and text color
      case 3:
        return const Color(0xFF1B4721); // Search icon and text color
      default:
        return Colors.white;
    }
  }
}
