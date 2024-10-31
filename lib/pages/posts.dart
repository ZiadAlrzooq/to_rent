import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              textDirection: TextDirection.rtl, // Right-to-left alignment
              textAlign: TextAlign.right, // Align text to the right
              decoration: InputDecoration(
                hintText: '...أبحث', // Arabic placeholder
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      // Image on the left with left margin
                      Container(
                        width: 100, // Set the width percentage you prefer
                        height: 100, // Match the height to the vertical space
                        margin: const EdgeInsets.only(left: 8.0), // Add left margin to the image
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(posts[index]['image']!),
                            fit: BoxFit.cover, // Cover the entire area
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Space between image and text
                      Expanded( // Take the remaining width
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // Align text to the end
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                posts[index]['title']!,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right, // Right align the title
                              ),
                              SizedBox(height: 4), // Space between title and username
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // User Icon
                                  Text(
                                    posts[index]['username']!,
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.right, // Right align the username
                                  ),
                                  SizedBox(width: 4), // Space between icon and username
                                  Icon(Icons.person, size: 16, color: Colors.grey),
                                ],
                              ),
                              SizedBox(height: 4), // Space between username and location/time
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end, // Align to the end
                                children: [
                                  // Location Icon
                                  Row(
                                    children: [
                                      Text(
                                        posts[index]['location']!,
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                        textAlign: TextAlign.right, // Right align the location
                                      ),
                                      SizedBox(width: 4), // Space between icon and text
                                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                  SizedBox(width: 16), // Space between location and time
                                  // Time Icon
                                  Row(
                                    children: [
                                      Text(
                                        posts[index]['time']!,
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                        textAlign: TextAlign.right, // Right align the time
                                      ),
                                      SizedBox(width: 4), // Space between icon and text
                                      Icon(Icons.access_time, size: 16, color: Colors.grey),
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
        margin: const EdgeInsets.only(bottom: 16.0, right: 16.0), // Margin from bottom and right
        child: FloatingActionButton(
          onPressed: () {
            // Add functionality to create a new post
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          shape: CircleBorder(), // Circular button shape
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Align button to the end (right)
    );
  }
}
