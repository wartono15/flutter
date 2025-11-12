import 'package:flutter/material.dart';
import 'form_page.dart';
import 'api_services.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Map<String, dynamic>> students = [];
  Map<String, dynamic>? selectedStudent;
  String searchQuery = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await ApiService.getStudents(q: searchQuery);
    setState(() {
      students = data;
      loading = false;
    });
  }

  _showDetails(Map<String, dynamic> s) {
    setState(() => selectedStudent = s);
  }

  _delete(int id) async {
    final ok = await ApiService.deleteStudent(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(ok ? 'Berhasil dihapus' : 'Gagal menghapus')));
    if (ok) _load();
  }

  _edit(Map<String, dynamic> s) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPage(student: s)),
    );
    if (res == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Mahasiswa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPage()),
          );
          if (res == true) _load();
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // 🔍 Kolom pencarian
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Cari berdasarkan nama...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() => searchQuery = val);
                      _load();
                    },
                  ),
                  const SizedBox(height: 12),

                  // 📋 Detail Mahasiswa Terpilih
                  if (selectedStudent != null) ...[
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                selectedStudent!['photo_url'] ?? '',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported, size: 80),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Nama: ${selectedStudent!['name']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Email: ${selectedStudent!['email']}"),
                            Text("Umur: ${selectedStudent!['age']}"),
                            Text("Jenis Kelamin: ${selectedStudent!['gender']}"),
                            Text("Status: ${selectedStudent!['status']}"),
                            Text("Hobi: ${selectedStudent!['hobbies']}"),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Divider(),

                  // 📜 Daftar Mahasiswa
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, i) {
                          final s = students[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              onTap: () => _showDetails(s),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  s['photo_url'] ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.person, size: 40),
                                ),
                              ),
                              title: Text(s['name'] ?? ''),
                              subtitle: Text(s['email'] ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _edit(s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _delete(int.parse(s['id'].toString())),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
