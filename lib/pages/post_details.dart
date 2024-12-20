import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago_ar;
import 'package:to_rent/pages/create_post.dart' show RentalPost;
import 'package:to_rent/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Image Gallery Screen
class ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            '${currentIndex + 1}/${widget.images.length}',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: PhotoViewGallery.builder(
          pageController: pageController,
          itemCount: widget.images.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(widget.images[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}

// Add Comment Model
class Comment {
  final String id;
  final String commenterId;
  final String username;
  final String profilePicture;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.commenterId,
    required this.username,
    required this.profilePicture,
    required this.content,
    required this.timestamp,
  });
}

// Update Post Model to include comments
class Post {
  final String username;
  final String profilePicture;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String unit;
  final DateTime timestamp;
  final String location;
  final String phoneNumber;
  final List<Comment> comments;

  Post({
    required this.username,
    required this.profilePicture,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.unit,
    required this.timestamp,
    required this.location,
    required this.phoneNumber,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}

class PostPage extends StatefulWidget {
  final String postId;

  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  Post? post;
  bool isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? posterId;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  Future<void> fetchPost() async {
    try {
      // Fetch post data from Firestore using widget.postId
      DocumentSnapshot postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (!postDoc.exists) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('المنشور غير موجود')),
        );
        return;
      }

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;

      // Get posterId from post data
      posterId = postData['posterId'];

      // Get username from usernames collection
      QuerySnapshot usernameSnapshot = await FirebaseFirestore.instance
          .collection('usernames')
          .where('uid', isEqualTo: posterId)
          .limit(1)
          .get();

      String username = 'Unknown';
      if (usernameSnapshot.docs.isNotEmpty) {
        username = usernameSnapshot.docs.first.id;
      }

      // Get profile picture from users collection using posterId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(posterId)
          .get();

      String profilePicture = '';
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        profilePicture = data?['profilePicture'] as String? ?? '';
      }

      // Get comments subcollection from post document
      QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .get();

      List<Comment> comments = [];

      for (var commentDoc in commentsSnapshot.docs) {
        Map<String, dynamic> commentData =
            commentDoc.data() as Map<String, dynamic>;

        String commenterId = commentData['uid'];
        String commenterUsername = 'Anonymous';
        String commenterProfilePicture = '';

        // Get commenter's username
        QuerySnapshot commenterUsernameSnapshot = await FirebaseFirestore
            .instance
            .collection('usernames')
            .where('uid', isEqualTo: commenterId)
            .limit(1)
            .get();

        if (commenterUsernameSnapshot.docs.isNotEmpty) {
          commenterUsername = commenterUsernameSnapshot.docs.first.id;
        }

        // Get commenter's profile picture
        DocumentSnapshot commenterUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(commenterId)
            .get();

        if (commenterUserDoc.exists) {
          final data = commenterUserDoc.data() as Map<String, dynamic>?;
          commenterProfilePicture = data?['profilePicture'] as String? ?? '';
        }

        // Parse timestamp
        DateTime timestamp;
        if (commentData['timestamp'] is Timestamp) {
          timestamp = (commentData['timestamp'] as Timestamp).toDate();
        } else if (commentData['timestamp'] is String) {
          timestamp = DateTime.parse(commentData['timestamp']);
        } else {
          timestamp = DateTime.now();
        }

        comments.add(Comment(
          id: commentDoc.id,
          commenterId: commenterId,
          username: commenterUsername,
          profilePicture: commenterProfilePicture,
          content: commentData['content'] ?? '',
          timestamp: timestamp,
        ));
      }

      // Create Post object
      Post fetchedPost = Post(
        username: username,
        profilePicture: profilePicture,
        title: postData['title'] ?? '',
        description: postData['description'] ?? '',
        images: List<String>.from(postData['imageUrls'] ?? []),
        price: (postData['rentPrice'] ?? 0).toDouble(),
        unit: postData['rentType'] ?? '',
        timestamp: (postData['createdDate'] as Timestamp).toDate(),
        location: postData['location'] ?? '',
        phoneNumber: postData['phoneNumber'] ?? '',
        comments: comments,
      );

      setState(() {
        post = fetchedPost;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل المنشور')),
      );
      print('Error fetching post: $e');
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    // Show loading indicator
    final loadingSnackBar = SnackBar(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('جاري إرسال التعليق...'),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);

    try {
      // send comment to Firestore using uid, content, timestamp
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'content': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Clear input and show success message
      _commentController.clear();
      _commentFocusNode.unfocus();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إضافة التعليق بنجاح')),
      );

      // Refresh post data to show new comment
      await fetchPost();
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في إرسال التعليق')),
      );
    }
  }

  void _openImageGallery(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          images: post!.images,
          initialIndex: index,
        ),
      ),
    );
  }

  void _navigateToEdit() {
    final rentalPost = RentalPost(
      id: widget.postId,
      title: post!.title,
      description: post!.description,
      imageUrls: post!.images,
      rentPrice: post!.price,
      rentType: post!.unit,
      createdDate: Timestamp.fromDate(post!.timestamp),
      location: post!.location,
      phoneNumber: post!.phoneNumber,
      posterId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    Navigator.pushNamed(
      context,
      '/create-post',
      arguments: rentalPost,
    );
  }
  // it should prompt the user to confirm the deletion
  void _deletePost() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('حذف المنشور'),
          content: Text('هل أنت متأكد من حذف المنشور؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  var firestoreService = FirestoreService(); // Create an instance
                  await firestoreService.deletePost(widget.postId);
                  Navigator.of(context).pushNamed('/posts');
                  // Show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف المنشور بنجاح'),
                    ),
                  );
                } catch (e) {
                  print('Error deleting post: $e');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ في حذف المنشور'),
                    ),
                  );
                }
              },
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    timeago_ar.setLocaleMessages('ar', timeago_ar.ArMessages());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المنشور'),
          centerTitle: true,
          actions: [
          if (FirebaseAuth.instance.currentUser?.uid == posterId) // Only show for post owner
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEdit();
                } else if (value == 'delete') {
                  _deletePost();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('تعديل المنشورة'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('حذف المنشورة'),
                  ),
                ];
              },
              icon: Icon(Icons.more_vert),
            ),
        ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushNamed('/posts');
            },
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : post == null
                ? Center(child: Text('لا يوجد منشور'))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User info section
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed('/profile/${posterId}');
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                post!.profilePicture),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        post!.username,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Title
                                Text(
                                  post!.title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.grey, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      post!.location,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(Icons.access_time,
                                        color: Colors.grey, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      timeago.format(post!.timestamp,
                                          locale: 'ar'),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Images
                                if (post!.images.isNotEmpty)
                                  Container(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: post!.images.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () => _openImageGallery(index),
                                          child: Container(
                                            margin: EdgeInsets.only(left: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Stack(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:
                                                        post!.images[index],
                                                    width: 200,
                                                    height: 200,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Positioned.fill(
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _openImageGallery(
                                                                index),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(height: 16),

                                // Description
                                Text(
                                  post!.description,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 16),

                                // Price and unit
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'السعر:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${post!.price} ر.س ${post!.unit}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Contact Button
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    String androidUrl =
                                        "whatsapp://send?phone=${post!.phoneNumber}";
                                    String iosUrl =
                                        "https://wa.me/${post!.phoneNumber}";
                                    Uri url = Uri.parse(androidUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  icon: FaIcon(FontAwesomeIcons.whatsapp),
                                  label: Text('تواصل عبر الواتساب'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                                SizedBox(height: 24),

                                if (post!.comments.isNotEmpty) ...[
                                  Text(
                                    'التعليقات',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ...(post!.comments.toList()
                                        ..sort((a, b) =>
                                            a.timestamp.compareTo(b.timestamp)))
                                      .map((comment) => Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 12),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          print(comment
                                                              .commenterId);
                                                          Navigator.of(context)
                                                              .pushNamed(
                                                                  '/profile/${comment.commenterId}');
                                                        },
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 16,
                                                              backgroundImage: comment.profilePicture.isNotEmpty
                                                                  ? NetworkImage(comment.profilePicture)
                                                                  : null,
                                                              child: comment.profilePicture.isEmpty
                                                                  ? Icon(Icons.person)
                                                                  : null,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              comment.username,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        timeago.format(
                                                            comment.timestamp,
                                                            locale: 'ar'),
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(comment.content),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(16).copyWith(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'اكتب تعليقاً...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _submitComment(),
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              onPressed: _submitComment,
                              icon: Icon(Icons.send),
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
