import 'package:flutter/material.dart';
import 'package:football_news/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:football_news/screens/menu.dart';

class NewsFormPage extends StatefulWidget {
  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _content = "";
  String _category = "update"; 
  String _thumbnail = "";
  bool _isFeatured = false; 

  final List<String> _categories = [
    'transfer',
    'update',
    'exclusive',
    'match',
    'rumor',
    'analysis',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
      title: const Center(
        child: Text(
        'Form Tambah Berita',
        ),
      ),
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // === Title ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
            decoration: InputDecoration(
              hintText: "Judul Berita",
              labelText: "Judul Berita",
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onChanged: (String? value) {
              setState(() {
              _title = value ?? "";
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
              return "Judul tidak boleh kosong!";
              }
              return null;
            },
            ),
          ),

          // === Content ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Isi Berita",
              labelText: "Isi Berita",
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onChanged: (String? value) {
              setState(() {
              _content = value ?? "";
              });
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
              return "Isi berita tidak boleh kosong!";
              }
              return null;
            },
            ),
          ),

          // === Category ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Kategori",
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            value: _category,
            items: _categories
              .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat[0].toUpperCase() + cat.substring(1)),
                ))
              .toList(),
            onChanged: (String? newValue) {
              setState(() {
              _category = newValue ?? _category;
              });
            },
            ),
          ),

          // === Thumbnail URL ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
            decoration: InputDecoration(
              hintText: "URL Thumbnail (opsional)",
              labelText: "URL Thumbnail",
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onChanged: (String? value) {
              setState(() {
              _thumbnail = value ?? "";
              });
            },
            ),
          ),

          // === Is Featured ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SwitchListTile(
            title: const Text("Tandai sebagai Berita Unggulan"),
            value: _isFeatured,
            onChanged: (bool value) {
              setState(() {
              _isFeatured = value;
              });
            },
            ),
          ),

          // === Tombol Simpan ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.indigo),
              ),
              onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  // TODO: Replace the URL with your app's URL
                  // To connect Android emulator with Django on localhost, use URL http://10.0.2.2/
                  // If you using chrome, use URL http://localhost:8000
                  
                  final response = await request.postJson(
                    "http://localhost:8000/create-flutter/",
                    jsonEncode({
                      "title": _title,
                      "content": _content,
                      "thumbnail": _thumbnail,
                      "category": _category,
                      "is_featured": _isFeatured,
                    }),
                  );

                  if (context.mounted) {
                    // Close loading indicator
                    Navigator.pop(context);
                    
                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                          content: Text("News successfully saved!"),
                        ));
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(
                            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)
                          )
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                          content: Text("Something went wrong, please try again."),
                        ));
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Close loading indicator if it's showing
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                        content: Text("Error: $e"),
                        duration: const Duration(seconds: 5),
                      ));
                  }
                }
              }
              },
              child: const Text(
              "Simpan",
              style: TextStyle(color: Colors.white),
              ),
            ),
            ),
          ),
          ],
        ),
        ),
      ),
      ),
    );
  }
}
