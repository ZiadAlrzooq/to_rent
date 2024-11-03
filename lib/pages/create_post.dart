import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class RentalPost {
  final String? id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final double rentPrice;
  final String rentType;
  final String posterId;
  final Timestamp createdDate;
  final String location;
  final String phoneNumber;

  RentalPost({
    this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.rentPrice,
    required this.rentType,
    required this.posterId,
    required this.createdDate,
    required this.location,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'rentPrice': rentPrice,
      'rentType': rentType,
      'posterId': posterId,
      'createdDate': createdDate,
      'location': location,
      'phoneNumber': phoneNumber,
    };
  }

  factory RentalPost.fromMap(Map<String, dynamic> map, String id) {
    return RentalPost(
      id: id,
      title: map['title'],
      description: map['description'],
      imageUrls: List<String>.from(map['imageUrls']),
      rentPrice: map['rentPrice'],
      rentType: map['rentType'],
      posterId: map['posterId'],
      createdDate: map['createdDate'],
      location: map['location'],
      phoneNumber: map['phoneNumber'],
    );
  }
}

class RentalPostForm extends StatefulWidget {
  final RentalPost? post; // If provided, we're editing an existing post
  final Function(RentalPost) onSubmit;
  const RentalPostForm({
    Key? key,
    this.post,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _RentalPostFormState createState() => _RentalPostFormState();
}

class _RentalPostFormState extends State<RentalPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentPriceController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  String _selectedRentType = 'يوم';
  String _selectedLocation = 'الرياض';
  List<File> _imageFiles = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  final List<String> _rentTypes = ['ساعة', 'يوم', 'أسبوع', 'شهر'];
  final List<String> _locations = [
    'الرياض',
    'جدة',
    'مكة',
    'الدمام',
    'المدينة',
    'الخبر',
    'أبها',
    'تبوك',
    'الطائف'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _descriptionController.text = widget.post!.description;
      _rentPriceController.text = widget.post!.rentPrice.toString();
      _phoneNumberController.text = widget.post!.phoneNumber;
      _selectedRentType = widget.post!.rentType;
      _selectedLocation = widget.post!.location;
      _existingImageUrls = widget.post!.imageUrls;
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (_imageFiles.length + images.length + _existingImageUrls.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الحد الأقصى للصور هو 10')),
        );
        return;
      }

      setState(() {
        _imageFiles.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> uploadedUrls = [];

    for (File imageFile in _imageFiles) {
      // upload the images and get the download URLs
    }

    return uploadedUrls;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFiles.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة صورة واحدة على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<String> newImageUrls = await _uploadImages();
      final allImageUrls = [..._existingImageUrls, ...newImageUrls];

      final post = RentalPost(
        id: widget.post?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrls: allImageUrls,
        rentPrice: double.parse(_rentPriceController.text),
        rentType: _selectedRentType,
        posterId: FirebaseAuth.instance.currentUser!.uid,
        createdDate: Timestamp.now(),
        location: _selectedLocation,
        phoneNumber: _phoneNumberController.text,
      );

      widget.onSubmit(post);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post == null ? 'نشر إعلان' : 'تعديل الإعلان'),
        ),
        body: Directionality(
            textDirection: TextDirection.rtl,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration:
                          const InputDecoration(labelText: 'عنوان الإعلان'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال عنوان الإعلان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'وصف الإعلان'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال وصف الإعلان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rentPriceController,
                      decoration: const InputDecoration(labelText: 'السعر'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال السعر';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'يرجى إدخال سعر صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedRentType,
                      decoration:
                          const InputDecoration(labelText: 'نوع الإيجار'),
                      items: _rentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRentType = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      decoration: const InputDecoration(labelText: 'الموقع'),
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedLocation = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration:
                          const InputDecoration(labelText: 'رقم الجوال'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الجوال';
                        }
                        if (value.length != 10) {
                          return 'يجب أن يتكون رقم الجوال من 10 أرقام';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('إضافة صور'),
                    ),
                    const SizedBox(height: 8),
                    if (_existingImageUrls.isNotEmpty || _imageFiles.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._existingImageUrls.map((url) => Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Stack(
                                    children: [
                                      Image.network(url, height: 100),
                                      Positioned(
                                        right: -10,
                                        top: -10,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _existingImageUrls.remove(url);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            ..._imageFiles.map((file) => Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Stack(
                                    children: [
                                      Image.file(file, height: 100),
                                      Positioned(
                                        right: -10,
                                        top: -10,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _imageFiles.remove(file);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(widget.post == null
                              ? 'نشر الإعلان'
                              : 'تحديث الإعلان'),
                    ),
                  ],
                ),
              ),
            )));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentPriceController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
