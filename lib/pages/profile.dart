import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_rent/pages/chat_details.dart';
import 'package:to_rent/services/firestore_service.dart';
import 'package:to_rent/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:to_rent/services/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:to_rent/services/chat_service.dart';

class ProfileFeed extends StatefulWidget {
  final String? uid;
  const ProfileFeed({Key? key, this.uid}) : super(key: key);

  @override
  _ProfileFeedState createState() => _ProfileFeedState();
}

class _ProfileFeedState extends State<ProfileFeed> {
  late Future<Map<String, dynamic>> _userProfileData;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final userId = widget.uid ?? user?.uid;

      if (userId != null) {
        _userProfileData = FirestoreService().getUserProfileData(userId);
      }

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'الملف الشخصي'),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userProfileData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data found'));
            } else {
              final profileData = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Card
                    ProfileCard(
                      uid: profileData['uid'],
                      username: profileData['username'],
                      profilePicture: profileData['profilePicture'],
                      initialRating: profileData['rating'],
                      ratingCount: profileData['ratingCount'],
                    ),
                    // Posts Card
                    const PostsCard(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  final String uid;
  final String username;
  final String profilePicture;
  final int initialRating;
  final int ratingCount;

  const ProfileCard({
    Key? key,
    required this.uid,
    required this.username,
    required this.profilePicture,
    required this.initialRating,
    required this.ratingCount,
  }) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late int _currentRating;
  late bool isViewingSelf;
  late String profilePicture;
  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;

    final currentUserUid =
        Provider.of<AuthProvider>(context, listen: false).user?.uid;
    isViewingSelf = currentUserUid == widget.uid;
    profilePicture = widget.profilePicture;
  }

  Future<void> _updateRating(int newRating) async {
    // TODO: Update rating to backend
    // TODO: also update ratingCount
    // TODO: show recent posts
    await Future.delayed(Duration(seconds: 1));
    print('Rating updated to backend: $newRating');
  }

  void _onStarTapped(int rating) {
    if (isViewingSelf || _currentRating == rating) return;

    setState(() {
      _currentRating = rating;
    });
    _updateRating(rating);
  }

  void _changeProfilePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 120,
          maxWidth: 120,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'قص الصورة',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true)
          ]);

      if (croppedFile != null) {
        Uri url =
            Uri.parse('https://api.cloudinary.com/v1_1/dxz9qstgg/image/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'tf66mt21'
          ..files
              .add(await http.MultipartFile.fromPath('file', croppedFile.path));
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.toBytes();
          final responseString = String.fromCharCodes(responseData);
          final jsonMap = jsonDecode(responseString);
          final newProfilePicture = jsonMap['url'];
          // upload new profile picture to Firestore
          try {
            await FirestoreService()
                .updateProfilePicture(widget.uid, newProfilePicture);
            setState(() {
              profilePicture = newProfilePicture;
            });
          } catch (e) {
            // show error message
            print('Error updating profile picture: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: profilePicture.isNotEmpty
                  ? NetworkImage(profilePicture)
                  : null,
              child: profilePicture.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '(${widget.ratingCount})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () => _onStarTapped(index + 1),
                            child: Icon(
                              Icons.star,
                              color: index < _currentRating
                                  ? Colors.orange
                                  : Colors.grey,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                      if (isViewingSelf)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'تقييمك',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isViewingSelf) ...[
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'change_picture') {
                    _changeProfilePicture();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'change_picture',
                    child: Text('تغيير صورة الملف الشخصي'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
                offset: const Offset(0, 40),
              ),
            ],
            if (!isViewingSelf) ...[
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // get chatid function
                  // navigate to chat page
                  ChatService().getChatId(
                    Provider.of<AuthProvider>(context, listen: false).user!.uid,
                    widget.uid,
                  ).then((chatId) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ChatScreen(
                        chatId: chatId,
                        otherUsername: widget.username,
                        otherProfilePicture: profilePicture,
                      );
                    }));
                  });
                },
                icon: const Icon(Icons.message, size: 18),
                label: const Text('تواصل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PostsCard extends StatelessWidget {
  const PostsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building posts card');
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'العروض',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              PostCard(
                imageUrl: 'assets/vase.jpg',
                description:
                    'مزهرية سيراميك مصنوعة يدوياً، تضيف لمسة من الأناقة لأي غرفة.',
              ),
              PostCard(
                imageUrl: 'assets/handbag.jpg',
                description:
                    'حقيبة يد جلدية أنيقة مع تفاصيل ذهبية، ملحق مثالي لأي مناسبة.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String imageUrl;
  final String description;

  const PostCard({
    Key? key,
    required this.imageUrl,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              description,
              style: const TextStyle(fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
