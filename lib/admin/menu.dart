import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/admin/menu_add.dart';
import 'package:moriana_mobile/admin/menu_edit.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:provider/provider.dart';

class MenuAdminScreen extends StatefulWidget {
  const MenuAdminScreen({super.key});

  @override
  State<MenuAdminScreen> createState() => _MenuAdminScreenState();
}

class _MenuAdminScreenState extends State<MenuAdminScreen> {
  @override
  Widget build(BuildContext context) {
  final menus = Provider.of<MenuProvider>(context).menuList;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                            image: CachedNetworkImageProvider(menu.imageURL),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.nmMenu,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: menu.isian.length,
                          itemBuilder: (context, isianIndex) {
                            final item = menu.isian[isianIndex];

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp.${menu.harga}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menu.ukuran,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => MenuEditScreen(menuData: menu))
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final provider = Provider.of<MenuProvider>(context, listen: false);
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Menu"),
                        content: const Text("Yakin ingin menghapus menu ini?"),
                        actions: [
                          TextButton(
                            child: const Text("Batal"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          ElevatedButton(
                            child: const Text("Hapus"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await provider.deleteMenu(menu.id);
                      await provider.deleteMenuImage(menu.id);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => MenuAddScreen())
          );
        },
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.green,
      ),
    );
  }
}