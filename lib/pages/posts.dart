import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_rent/pages/create_post.dart';
import 'package:to_rent/services/auth_service.dart';
import 'package:to_rent/widgets/custom_app_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  List<Map<String, dynamic>> posts = [];
  TextEditingController searchController = TextEditingController();
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  bool isSearching = false;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchPosts(isInitialLoad: true);

    // Listener for infinite scrolling
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (isSearching) {
          searchPosts(paginate: true);
        } else {
          fetchPosts();
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Fetch all posts with pagination
  void fetchPosts({bool isInitialLoad = false}) async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance.collection('posts').orderBy('createdDate', descending: true).limit(10);

    if (lastDocument != null && !isInitialLoad) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;

      List<Map<String, dynamic>> fetchedPosts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
        post['id'] = doc.id;
        post['createdDate'] = (post['createdDate'])?.toDate();
        return post;
      }).toList();

      setState(() {
        if (isInitialLoad) {
          posts = fetchedPosts;
        } else {
          posts.addAll(fetchedPosts);
        }
        hasMore = fetchedPosts.length == 10;
      });
    } else {
      setState(() {
        hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Search posts with pagination and ranking
  void searchPosts({bool paginate = false}) async {
    String searchText = searchController.text.trim();

    if (searchText.isEmpty) {
      // Reset search state and fetch all posts
      isSearching = false;
      lastDocument = null;
      hasMore = true;
      fetchPosts(isInitialLoad: true);
      return;
    }

    if (isLoading || (!paginate && lastDocument != null)) return;
    setState(() {
      isLoading = true;
      isSearching = true;
    });

    List<String> trigrams = extractTrigrams(searchText);

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .where('trigrams', arrayContainsAny: trigrams)
        .orderBy('createdDate', descending: true)
        .limit(10);

    if (lastDocument != null && paginate) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;

      List<Map<String, dynamic>> rankedPosts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
        post['id'] = doc.id;
        post['createdDate'] = (post['createdDate'])?.toDate();

        // Calculate the score based on matching trigrams
        List<String> postTrigrams = List<String>.from(post['trigrams']);
        int score = trigrams.where((t) => postTrigrams.contains(t)).length;
        post['score'] = score;

        return post;
      }).toList();

      // Sort the posts by score in descending order
      rankedPosts.sort((a, b) => b['score'].compareTo(a['score']));

      setState(() {
        if (!paginate) {
          posts = rankedPosts;
        } else {
          posts.addAll(rankedPosts);
        }
        hasMore = rankedPosts.length == 10;
      });
    } else {
      setState(() {
        hasMore = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Extract trigrams from search text
  List<String> extractTrigrams(String text) {
    text = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    List<String> trigrams = [];
    for (int i = 0; i < text.length - 2; i++) {
      trigrams.add(text.substring(i, i + 3));
    }
    return trigrams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'المنشورات'),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: '...أبحث',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    lastDocument = null;
                    hasMore = true;
                    searchPosts();
                  },
                  child: Text('بحث'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('usernames')
                      .where('uid', isEqualTo: posts[index]['posterId'])
                      .limit(1)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      String username = snapshot.data!.docs.first.id;
                      return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/posts/${posts[index]['id']}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            posts[index]['imageUrls'][0]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          posts[index]['title'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Icon(Icons.person,
                                                size: 16,
                                                color: Colors.black),
                                            SizedBox(width: 8),
                                            Flexible(
                                            child: Text(
                                              username,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                            SizedBox(width: 16),
                                            Icon(Icons.access_time,
                                                size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              timeago.format(
                                                  posts[index]['createdDate'],
                                                  locale: 'ar'),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                posts[index]['location'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(Icons.attach_money,
                                                size: 16, color: Colors.grey),
                                            Text(
                                              posts[index]['rentPrice']
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              ' لكل ${posts[index]['rentType']}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-post');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
