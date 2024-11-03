import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_rent/pages/create_post.dart';
import 'package:to_rent/services/auth_service.dart';
import 'package:to_rent/widgets/custom_app_bar.dart';

class Posts extends StatelessWidget {
  final List<Map<String, String>> posts = [
    {
      'title': 'عنوان المنشور 1', // Post Title
      'username': 'اسم المستخدم 1', // Username
      'location': 'الرياض', // Location
      'time': 'قبل ساعة', // Relative Time
      'image': 'https://picsum.photos/200', // Image URL
    },
    {
      'title': 'عنوان المنشور 2',
      'username': 'اسم المستخدم 2',
      'location': 'جدة',
      'time': 'قبل 2 ساعة',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'عنوان المنشور 3',
      'username': 'اسم المستخدم 3',
      'location': 'المدينة المنورة',
      'time': 'قبل 3 ساعة',
      'image': 'https://via.placeholder.com/150',
    },
    // Add more posts as needed
  ];

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
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(left: 8.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(posts[index]['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                posts[index]['title']!,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    posts[index]['username']!,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.person,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        posts[index]['location']!,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.location_on,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                  SizedBox(width: 16),
                                  Row(
                                    children: [
                                      Text(
                                        posts[index]['time']!,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.access_time,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
            Navigator.pushNamed(context, '/create-post',
                arguments: RentalPost(
                    title: 'Sample Title', // Replace with actual title
                    description:
                        'Sample Description', // Replace with actual description
                    imageUrls: [
                      'https://picsum.photos/200/300',
                      'https://picsum.photos/200/300'
                    ], // Replace with actual image URLs
                    rentPrice: 1000.0, // Replace with actual rent price
                    rentType: 'شهر', // Replace with actual rent type
                    posterId: 'user123', // Replace with actual poster ID
                    createdDate:
                        Timestamp(1234567890, 0), // Replace with actual date
                    location: 'الرياض', // Replace with actual location
                    phoneNumber:
                        '123-456-7890' // Replace with actual phone number
                    ));
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
