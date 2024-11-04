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

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchPosts();
  }

  void fetchPosts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    setState(() {
      posts = documents.map((doc) {
        Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
        post['id'] = doc.id;
        post['createdDate'] = (post['createdDate'])?.toDate();
        return post;
      }).toList();
    });
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
            child: TextField(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '...أبحث',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onChanged: (value) {
                // Implement search functionality here
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            size: 16, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text(
                                          username,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.right,
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
                                              fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.right,
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
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(Icons.attach_money,
                                            size: 16, color: Colors.grey),
                                        Text(
                                          posts[index]['rentPrice'].toString(),
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          ' لكل ${posts[index]['rentType']}',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            // make it navigate to the new post page
            Navigator.pushNamed(context, '/create-post');
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
//createdDate