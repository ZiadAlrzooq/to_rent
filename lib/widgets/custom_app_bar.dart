import 'package:flutter/material.dart';
import 'package:to_rent/services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100.0, // Adjust the height as needed
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'القائمة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text('المنشورات'),
            selected: currentRoute == '/posts',
            onTap: () {
              if (currentRoute != '/posts') {
                Navigator.pushReplacementNamed(context, '/posts');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('الملف الشخصي'),
            selected: currentRoute == '/profile',
            onTap: () {
              if (currentRoute != '/profile') {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('الدردشات'),
            selected: currentRoute == '/chats',
            onTap: () {
              if (currentRoute != '/chats') {
                Navigator.pushReplacementNamed(context, '/chats');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('تسجيل خروج'),
            onTap: () {
              AuthService().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}