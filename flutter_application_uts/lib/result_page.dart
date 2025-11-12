import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'form_page.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  void _loadUsers() async {
    final users = await ApiService.getUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users
          .where((u) => u['nama'].toLowerCase().contains(keyword))
          .toList();
    });
  }

  void _deleteUser(String id) async {
    bool success = await ApiService.deleteUser(id);
    if (success) {
      _loadUsers();
    }
  }

  void _editUser(dynamic user) async {
    final namaController = TextEditingController(text: user['nama']);
    final emailController = TextEditingController(text: user['email']);
    final umurController = TextEditingController(text: user['umur']);
    String? jenisKelamin = user['jenis_kelamin'];
    File? newImage;
    final picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Data"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: namaController, decoration: InputDecoration(labelText: "Nama")),
                TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
                TextField(controller: umurController, decoration: InputDecoration(labelText: "Umur")),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text("Laki-laki"),
                        value: "Laki-laki",
                        groupValue: jenisKelamin,
                        onChanged: (value) => setState(() => jenisKelamin = value.toString()),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: Text("Perempuan"),
                        value: "Perempuan",
                        groupValue: jenisKelamin,
                        onChanged: (value) => setState(() => jenisKelamin = value.toString()),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text("Ganti Foto"),
                  onPressed: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setState(() {
                        newImage = File(picked.path);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                Map<String, String> data = {
                  "id": user['id'],
                  "nama": namaController.text,
                  "email": emailController.text,
                  "umur": umurController.text,
                  "jenis_kelamin": jenisKelamin ?? "",
                };
                await ApiService.updateUser(data, newImage);
                Navigator.pop(context);
                _loadUsers();
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_users.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Hasil Data")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final newest = _users.first;

    return Scaffold(
      appBar: AppBar(title: Text("Data Mahasiswa")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: "Cari Nama...",
              ),
            ),
            SizedBox(height: 20),

            // Data terbaru
            if (newest != null) ...[
              if (newest['foto'] != null && newest['foto'].isNotEmpty)
                Image.network("http://10.0.2.2/flutter_api/${newest['foto']}", height: 120),
              SizedBox(height: 10),
              Text("Nama: ${newest['nama']}"),
              Text("Email: ${newest['email']}"),
              Text("Umur: ${newest['umur']}"),
              Text("Jenis Kelamin: ${newest['jenis_kelamin']}"),
              Text("Status: ${newest['status_mahasiswa']}"),
              Text("Hobi: ${newest['hobi']}"),
            ],

            Divider(height: 40, thickness: 2),

            // List semua data
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  child: ListTile(
                    leading: user['foto'] != null && user['foto'].isNotEmpty
                        ? Image.network("http://10.0.2.2/flutter_api/${user['foto']}")
                        : Icon(Icons.person),
                    title: Text(user['nama']),
                    subtitle: Text(user['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () => _editUser(user)),
                        IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteUser(user['id'])),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Tombol kembali
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FormPage()));
              },
              child: Text("Kembali ke Form"),
            ),
          ],
        ),
      ),
    );
  }
}
