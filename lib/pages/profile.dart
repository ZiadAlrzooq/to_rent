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
              ProfileCard(initialRating: 4), // Example initial rating

              // Posts Card
              PostsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  final int initialRating;

  const ProfileCard({Key? key, required this.initialRating}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating; // Set initial rating from backend
  }

  Future<void> _updateRating(int newRating) async {
    // Simulate sending the new rating to the backend
    await Future.delayed(Duration(seconds: 1));
    print('Rating updated to backend: $newRating'); // Replace with actual API call
  }

  void _onStarTapped(int rating) {
    setState(() {
      _currentRating = rating; // Update rating visually
    });
    _updateRating(rating); // Send new rating to backend
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          textDirection: TextDirection.rtl, // RTL layout
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () => _onStarTapped(index + 1), // Set rating on tap
                        child: Icon(
                          Icons.star,
                          color: index < _currentRating ? Colors.orange : Colors.grey,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add message functionality
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
                description: 'مزهرية سيراميك مصنوعة يدوياً، تضيف لمسة من الأناقة لأي غرفة.',
              ),
              PostCard(
                imageUrl: 'assets/handbag.jpg',
                description: 'حقيبة يد جلدية أنيقة مع تفاصيل ذهبية، ملحق مثالي لأي مناسبة.',
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
