import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_page.dart';
import 'api_service.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final umurController = TextEditingController();

  String? jenisKelamin;
  String? statusMahasiswa;
  List<String> hobiList = [];

  File? imageFile;

  final ImagePicker _picker = ImagePicker();

  // ambil gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // ambil gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void _resetForm() {
    setState(() {
      namaController.clear();
      emailController.clear();
      umurController.clear();
      jenisKelamin = null;
      statusMahasiswa = null;
      hobiList.clear();
      imageFile = null;
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 150,
        child: Column(
          children: [
            Text("Pilih Sumber Foto", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text("Kamera"),
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text("Galeri"),
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> data = {
        "nama": namaController.text,
        "email": emailController.text,
        "umur": umurController.text,
        "jenis_kelamin": jenisKelamin ?? "",
        "status_mahasiswa": statusMahasiswa ?? "",
        "hobi": hobiList.join(", "),
      };

      bool success = await ApiService.addUser(data, imageFile);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResultPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan data ke server")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form Input Data")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),

              SizedBox(height: 10),

              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Email tidak boleh kosong" : null,
              ),

              SizedBox(height: 10),

              // Umur
              TextFormField(
                controller: umurController,
                decoration: InputDecoration(
                  labelText: "Umur",
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Umur tidak boleh kosong" : null,
              ),

              SizedBox(height: 15),

              // Jenis Kelamin
              Text("Jenis Kelamin", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: Text("Laki-laki"),
                      value: "Laki-laki",
                      groupValue: jenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          jenisKelamin = value.toString();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Text("Perempuan"),
                      value: "Perempuan",
                      groupValue: jenisKelamin,
                      onChanged: (value) {
                        setState(() {
                          jenisKelamin = value.toString();
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Status Mahasiswa
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Status Mahasiswa",
                  prefixIcon: Icon(Icons.school),
                ),
                value: statusMahasiswa,
                items: [
                  "Aktif",
                  "Cuti",
                  "Lulus",
                ]
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    statusMahasiswa = value;
                  });
                },
              ),

              SizedBox(height: 15),

              // Hobi
              Text("Hobi", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: [
                  for (var hobby in ["Membaca", "Menulis", "Musik", "Olahraga", "Traveling"])
                    FilterChip(
                      label: Text(hobby),
                      selected: hobiList.contains(hobby),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? hobiList.add(hobby)
                              : hobiList.remove(hobby);
                        });
                      },
                    )
                ],
              ),

              SizedBox(height: 20),

              // Foto
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            imageFile != null ? FileImage(imageFile!) : null,
                        child: imageFile == null
                            ? Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("Klik ikon untuk ambil foto"),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Tombol kirim & reset
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _submitData,
                    child: Text("Kirim Data"),
                  ),
                  OutlinedButton(
                    onPressed: _resetForm,
                    child: Text("Reset"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
