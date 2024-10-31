import 'package:flutter/material.dart';

class ProfileFeed extends StatelessWidget {
  const ProfileFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Card
              ProfileCard(),

              // Posts Card
              PostsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          textDirection: TextDirection.rtl, // Reverses row direction for RTL layout
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Aligns text to the right
                children: [
                  const Text(
                    'الاسم الشخصي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Aligns stars to the right
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.orange,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add message functionality here
              },
              icon: const Icon(Icons.message, size: 18),
              label: const Text('رسالة'), // Arabic for "Message"
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
        ),
      ),
    );
  }
}

class PostsCard extends StatelessWidget {
  const PostsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'المنشورات الأخيرة', // Arabic for "Recent Posts"
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
                description: 'مزهرية سيراميك مصنوعة يدوياً، تضيف لمسة من الأناقة لأي غرفة.', // Arabic description
              ),
              PostCard(
                imageUrl: 'assets/handbag.jpg',
                description: 'حقيبة يد جلدية أنيقة مع تفاصيل ذهبية، ملحق مثالي لأي مناسبة.', // Arabic description
              ),
                            PostCard(
                imageUrl: 'assets/handbag.jpg',
                description: 'حقيبة يد جلدية أنيقة مع تفاصيل ذهبية، ملحق مثالي لأي مناسبة.', // Arabic description
              ),
                            PostCard(
                imageUrl: 'assets/handbag.jpg',
                description: 'حقيبة يد جلدية أنيقة مع تفاصيل ذهبية، ملحق مثالي لأي مناسبة.', // Arabic description
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
              textDirection: TextDirection.rtl, // Sets text direction to RTL
            ),
          ),
        ],
      ),
    );
  }
}
