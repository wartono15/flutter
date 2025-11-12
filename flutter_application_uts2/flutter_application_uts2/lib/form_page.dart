// lib/form_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_services.dart';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? student; // jika null => create, jika ada => edit
  const FormPage({super.key, this.student});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _age = TextEditingController();

  String _gender = 'Laki-laki';
  String _status = 'Aktif';
  List<String> _hobbies = [];
  File? _imageFile;
  Uint8List? _webImageBytes;
  String? _webImageName;
  String? existingPhotoUrl;
  int? editingId;

  final ImagePicker _picker = ImagePicker();
  List<String> hobbyOptions = ['Membaca', 'Menulis', 'Musik', 'Olahraga', 'Traveling'];

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final s = widget.student!;
      editingId = s['id'];
      _name.text = s['name'] ?? '';
      _email.text = s['email'] ?? '';
      _age.text = (s['age'] ?? '').toString();
      _gender = s['gender'] ?? 'Laki-laki';
      _status = s['status'] ?? 'Aktif';
      final h = s['hobbies'] ?? '';
      _hobbies = h.toString().isEmpty ? [] : h.toString().split(',').map((e) => e.trim()).toList();
      existingPhotoUrl = s['photo_url'];
    }
  }

  _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 80);
    if (picked == null) return;
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
        _webImageName = picked.name;
        _imageFile = null;
        existingPhotoUrl = null;
      });
    } else {
      setState(() {
        _imageFile = File(picked.path);
        _webImageBytes = null;
        _webImageName = null;
        existingPhotoUrl = null;
      });
    }
  }

  _reset() {
    _formKey.currentState?.reset();
    _name.clear();
    _email.clear();
    _age.clear();
    setState(() {
      _gender = 'Laki-laki';
      _status = 'Aktif';
      _hobbies.clear();
      _imageFile = null;
      _webImageBytes = null;
      _webImageName = null;
      existingPhotoUrl = null;
      editingId = null;
    });
  }

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final email = _email.text.trim();
    final age = int.tryParse(_age.text.trim()) ?? 0;
    final hobbiesCsv = _hobbies.join(', ');

    bool ok = false;
    if (editingId == null) {
      // insert
      ok = await ApiService.insertStudent(
        name: name,
        email: email,
        age: age,
        gender: _gender,
        status: _status,
        hobbies: hobbiesCsv,
        photo: _imageFile,
        photoBytes: _webImageBytes,
        filename: _webImageName,
      );
    } else {
      // update
      ok = await ApiService.updateStudent(
        id: editingId!,
        name: name,
        email: email,
        age: age,
        gender: _gender,
        status: _status,
        hobbies: hobbiesCsv,
        photo: _imageFile,
        photoBytes: _webImageBytes,
        filename: _webImageName,
      );
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Berhasil' : 'Gagal')));
    if (ok) {
      // kembali ke halaman sebelumnya dan minta reload
      Navigator.pop(context, true); // kembalikan true supaya pemanggil reload data
    }
  }

  Widget _iconTextField({required IconData icon, required String hint, required TextEditingController ctrl, TextInputType? type}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type ?? TextInputType.text,
      validator: (v) => (v==null || v.trim().isEmpty) ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const UnderlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editingId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Data' : 'Form Input Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 8),
            _iconTextField(icon: Icons.person, hint: 'Nama', ctrl: _name),
            const SizedBox(height: 12),
            _iconTextField(icon: Icons.email, hint: 'Email', ctrl: _email, type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _iconTextField(icon: Icons.tag, hint: 'Umur', ctrl: _age, type: TextInputType.number),
            const SizedBox(height: 18),
            Align(alignment: Alignment.centerLeft, child: Text('Jenis Kelamin', style: Theme.of(context).textTheme.titleMedium)),
            Row(
              children: [
                Radio<String>(value: 'Laki-laki', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)), const Text('Laki-laki'),
                const SizedBox(width: 20),
                Radio<String>(value: 'Perempuan', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!)), const Text('Perempuan'),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.school), labelText: 'Status Mahasiswa'),
              items: const [
                DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                DropdownMenuItem(value: 'Cuti', child: Text('Cuti')),
                DropdownMenuItem(value: 'Lulus', child: Text('Lulus')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 18),
            Align(alignment: Alignment.centerLeft, child: Text('Hobi', style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: hobbyOptions.map((h) {
                final selected = _hobbies.contains(h);
                return ChoiceChip(
                  label: Text(h),
                  selected: selected,
                  onSelected: (on) {
                    setState(() {
                      if (on) _hobbies.add(h); else _hobbies.remove(h);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => showModalBottomSheet(context: context, builder: (_) {
                return SafeArea(child: Wrap(children: [
                  ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Kamera'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
                  ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeri/File'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
                ]));
              }),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.purple[50],
                child: _imageFile == null && _webImageBytes == null && existingPhotoUrl == null
                    ? const Icon(Icons.camera_alt, size: 48, color: Colors.purple)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? (_webImageBytes != null ? Image.memory(_webImageBytes!, width: 120, height: 120, fit: BoxFit.cover) :
                               (existingPhotoUrl != null ? Image.network(existingPhotoUrl!, width: 120, height: 120, fit: BoxFit.cover) : const SizedBox()))
                            : (_imageFile != null ? Image.file(_imageFile!, width: 120, height: 120, fit: BoxFit.cover) :
                               (existingPhotoUrl != null ? Image.network(existingPhotoUrl!, width: 120, height: 120, fit: BoxFit.cover) : const SizedBox())),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(isEdit ? 'Ubah foto dengan klik ikon' : 'Klik ikon untuk ambil foto'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: _submit, child: Text(isEdit ? 'Simpan Perubahan' : 'Kirim Data')),
                OutlinedButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 60),
          ]),
        ),
      ),
    );
  }
}
