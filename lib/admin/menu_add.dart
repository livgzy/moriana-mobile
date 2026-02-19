import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import 'package:moriana_mobile/models/menu.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:moriana_mobile/services/firestore_service.dart';
import 'package:moriana_mobile/services/superbase_service.dart';
import 'package:provider/provider.dart';


class MenuAddScreen extends StatefulWidget {
  const MenuAddScreen({super.key});

  @override
  State<MenuAddScreen> createState() => _MenuAddScreenState();
}

class _MenuAddScreenState extends State<MenuAddScreen> {

  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();

  List<String> isiMenuList = [];
  Uint8List? imageData;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      imageData = await file.readAsBytes();
      setState(() {});
    }
  }

  void addIsiMenu() {
    if (_isiController.text.isNotEmpty) {
      setState(() {
        isiMenuList.add(_isiController.text);
        _isiController.clear();
      });
    }
  }

  Future<void> addMenu() async {
    final provider = Provider.of<MenuProvider>(context, listen: false);

    final String? imageURL = await SuperbaseService().uploadMenuImage(imageData!,  _kodeController.text);

    final createMenu = MenuModel(
      id: _kodeController.text,
      nmMenu: _nameController.text,
      harga: int.parse(_hargaController.text),
      isian: isiMenuList,
      ukuran: "${_ukuranController.text}ml",
      imageURL: imageURL!,
    );

    await FirestoreService().addMenu(createMenu, _kodeController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu Berhasil Ditambahkan"),
            backgroundColor: Colors.green,
          ),
      );              
    }

    await provider.loadMenus();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            TextField(
              controller: _nameController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: _boxDecoration("Menu"),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 5),
            TextField(
              controller: _kodeController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: _boxDecoration("Kode Menu"),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _isiController,
                    onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
                    decoration: _boxDecoration("Isian"),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                  onPressed: addIsiMenu,
                )
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: isiMenuList.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, 
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(item),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isiMenuList.remove(item);
                            });
                          },
                          child: const Icon(Icons.close, size: 16),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 5),
            TextField(
              controller: _hargaController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.number,
              decoration: _boxDecoration("Harga"),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 5),
            TextField(
              controller: _ukuranController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.number,
              decoration: _boxDecoration("Ukuran (ml)"),
            ),
            const SizedBox(height: 20),
            const Text("Gambar Menu:"),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageData != null
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          image: imageData != null
                              ? DecorationImage(
                                  image: MemoryImage(imageData!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      )      
                    : Center(
                        child: Icon(Icons.attach_file, color: Colors.blue[800], size: 35),
                      ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  if (imageData == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gambar menu harus diisi!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_nameController.text.isEmpty ||
                      _kodeController.text.isEmpty ||
                      _ukuranController.text.isEmpty ||
                      isiMenuList.isEmpty ||
                      _hargaController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Semua field wajib diisi!"),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  await addMenu();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Tambah Menu",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  InputDecoration _boxDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}