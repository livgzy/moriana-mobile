import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_providers.dart';
import '../models/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _alamatController;
  late TextEditingController _noHpController;
  Uint8List? _newImage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    _usernameController = TextEditingController(text: user?.username ?? "");
    _alamatController = TextEditingController(text: user?.alamat ?? "");
    _noHpController = TextEditingController(text: user?.noHp ?? "");
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

 

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    _newImage = await picked.readAsBytes();
    setState(() {});
  }

  Future<void> updateProfile() async {
    try {
      final provider = Provider.of<UserProvider>(context, listen: false);
      final user = provider.userData;
      if (user == null) return;

      final updatedUser = UserModel(
        email: user.email,
        username: _usernameController.text.trim(),
        alamat: _alamatController.text.trim(),
        noHp: _noHpController.text.trim(),
        status: user.status,
        createdAt: user.createdAt,
      );

      await provider.updateUser(updatedUser);

      if (_newImage != null) {
        await provider.updateUserImage(_newImage!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil Berhasil Diedit"),
              backgroundColor: Colors.green,
            ),
        );              
      }

    } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu Gagal Diedit"),
            backgroundColor: Colors.red,
          ),
      );              
    }
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userImage = _newImage ?? userProvider.userImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: userImage != null ? MemoryImage(userImage) : null,
                  child: userImage == null ? const Icon(Icons.person, size: 80) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green, // background hijau
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: pickImage,
                      padding: const EdgeInsets.all(4), // atur ukuran tombol
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _alamatController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                labelText: "Alamat",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noHpController,
              onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                labelText: "Nomor HP",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                 if (_noHpController.text.isEmpty ||
                      _alamatController.text.isEmpty ||
                      _usernameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Semua field harus diisi!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                await updateProfile();
                
              },
              child: const Text("Update Profile",style: TextStyle(color:Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
