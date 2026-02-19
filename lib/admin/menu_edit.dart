import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moriana_mobile/services/superbase_service.dart';
import 'package:provider/provider.dart';

import '../../models/menu.dart';
import '../../providers/menu_provider.dart';

class MenuEditScreen extends StatefulWidget {
  final MenuModel menuData;
  const MenuEditScreen({super.key, required this.menuData});

  @override
  State<MenuEditScreen> createState() => _MenuEditScreenState();
}

class _MenuEditScreenState extends State<MenuEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();

  List<String> isiMenuList = [];
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.menuData.nmMenu;
    _hargaController.text = widget.menuData.harga.toString();
    _ukuranController.text = widget.menuData.ukuran.replaceAll("ml", "");
    isiMenuList = List<String>.from(widget.menuData.isian);

  }

  @override
  void dispose() {
    _nameController.dispose();
    _hargaController.dispose();
    _ukuranController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      imageData = await file.readAsBytes();
      setState(() {});
    }
  }

  Future<void> updateMenu() async {
    final provider = Provider.of<MenuProvider>(context, listen: false);


    String? imageURL = widget.menuData.imageURL;
    if (imageData != null) {
      imageURL = await SuperbaseService().updateMenuImage(imageData!, widget.menuData.id);
    }

    final updateMenu = MenuModel(
      id: widget.menuData.id,
      nmMenu: _nameController.text,
      harga: int.parse(_hargaController.text),
      isian: isiMenuList,
      ukuran: "${_ukuranController.text}ml",
      imageURL: imageURL!,
    );


    await provider.updateMenu(updateMenu);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu Berhasil Diedit"),
            backgroundColor: Colors.green,
          ),
      );              
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    image: imageData != null
                          ? DecorationImage(
                            image: MemoryImage(imageData!),
                            fit: BoxFit.cover,
                          )
                          : DecorationImage(
                            image: CachedNetworkImageProvider(widget.menuData.imageURL),
                            fit: BoxFit.cover,
                          )
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 76, 175, 80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                labelText: "Nama Menu ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _hargaController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Harga",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _ukuranController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Ukuran (ml)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Isian Menu ${widget.menuData.id}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Wrap(
              spacing: 8,
              children: isiMenuList
                  .map(
                    (e) => Chip(
                      label: Text(e),
                      onDeleted: () {
                        setState(() {
                          isiMenuList.remove(e);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final ctrl = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Tambah Isian"),
                    content: TextField(
                      controller: ctrl,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (ctrl.text.isNotEmpty) {
                              isiMenuList.add(ctrl.text);
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Tambah"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Tambah Isian", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_nameController.text.isEmpty ||
                      _hargaController.text.isEmpty ||
                      isiMenuList.isEmpty ||
                      _ukuranController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Semua field harus diisi!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await updateMenu();
                  

                },
                child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
