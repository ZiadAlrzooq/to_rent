import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago_ar;
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
  final String username;
  final String profilePicture;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.username,
    required this.profilePicture,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      username: json['username'],
      profilePicture: json['profile_picture'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
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

  factory Post.fromJson(Map<String, dynamic> json) {
    var commentsList = json['comments'] as List?;
    List<Comment> comments = [];

    if (commentsList != null) {
      comments =
          commentsList.map((comment) => Comment.fromJson(comment)).toList();
    }

    return Post(
      username: json['username'],
      profilePicture: json['profile_picture'],
      title: json['title'],
      description: json['description'],
      images: List<String>.from(json['images']),
      price: json['price'].toDouble(),
      unit: json['unit'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      phoneNumber: json['phone_number'],
      comments: comments,
    );
  }
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
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      // Replace this with actual API call using widget.postId
      final response = {
        'username': 'أحمد محمد',
        'profile_picture': 'https://picsum.photos/seed/1/200/300',
        'title': 'شقة للإيجار',
        'description': 'شقة جميلة في حي راقي',
        'images': [
          'https://picsum.photos/seed/2/200/300',
          'https://picsum.photos/seed/3/200/300',
        ],
        'price': 1500.0,
        'unit': 'لكل شهر',
        'timestamp': '2024-03-01T10:00:00Z',
        'location': 'الرياض',
        'phone_number': '+966555555555',
        'comments': [
          {
            'id': '1',
            'username': 'محمد علي',
            'profile_picture': 'https://picsum.photos/seed/4/200/300',
            'content': 'هل العقار متوفر؟',
            'timestamp': '2024-03-01T12:00:00Z',
          },
          {
            'id': '2',
            'username': 'سارة أحمد',
            'profile_picture': 'https://picsum.photos/seed/5/200/300',
            'content': 'موقع ممتاز',
            'timestamp': '2024-03-01T13:30:00Z',
          },
        ],
      };

      setState(() {
        post = Post.fromJson(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل المنشور')),
      );
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
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      // Replace with actual API call

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

  @override
  Widget build(BuildContext context) {
    timeago_ar.setLocaleMessages('ar', timeago_ar.ArMessages());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المنشور'),
          centerTitle: true,
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
                                Row(
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
                                  ...post!.comments
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
                                                      CircleAvatar(
                                                        radius: 16,
                                                        backgroundImage:
                                                            CachedNetworkImageProvider(
                                                          comment
                                                              .profilePicture,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        comment.username,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
