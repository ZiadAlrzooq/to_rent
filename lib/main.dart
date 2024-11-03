import 'package:flutter/material.dart';
import 'package:to_rent/firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'pages/posts.dart';
import 'pages/post_details.dart'; // New import for the post detail page
import 'widgets/protected_route.dart';
import 'pages/profile.dart';
import 'pages/create_post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToRent App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'posts') {
          final postId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => ProtectedRoute(
              child: PostPage(postId: postId),
            ),
          );
        }
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => HomePage());
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => RegisterPage());
          case '/posts':
            return MaterialPageRoute(
              builder: (context) => ProtectedRoute(child: Posts()),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (context) => ProtectedRoute(child: ProfileFeed()),
            );
          case '/create-post':
            return MaterialPageRoute(
              builder: (context) {
                final RentalPost? post = settings.arguments as RentalPost?;
                return ProtectedRoute(
                  child: RentalPostForm(
                    post: post,
                    onSubmit: (post) {
                      // Handle the post submission
                    },
                  ),
                );
              },
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}
