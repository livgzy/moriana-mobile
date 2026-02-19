import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models/user.dart';
// import 'widgets/popout_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();


  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHPController = TextEditingController();
  final String _status = "Customer";
  final DateTime _createdAt = DateTime.now();

  bool _obscurePassword = true;
  late String _message = "";

  void registerUser() async {

    try {
      final user = await _auth.register(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        final userModel = UserModel(
          username: _usernameController.text,
          alamat: _alamatController.text,
          noHp: _noHPController.text,
          email: _emailController.text,
          status: _status,
          createdAt: _createdAt,
        );
        await _firestore.addUser(userModel, user.uid);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
          _message = "Sign In Gagal: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 28, 28, 28)

            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                      // style: GoogleFonts.balooBhai2(fontSize: 42, fontWeight: FontWeight.w600, color: Colors.white)
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: _usernameController,
                    hintText: "Username...",
                    maxLength: 30,
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  _buildInputField(
                    controller: _emailController,
                    hintText: "Email...",
                    icon: Icons.email,
                  ),
                  SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: "Password...",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 16),
                  _buildInputField(
                    controller: _alamatController,
                    hintText: "alamat...",
                    icon: Icons.home,
                  ),
                  SizedBox(height: 16),
                  _buildInputField(
                    controller: _noHPController,
                    hintText: "no HP...",
                    icon: Icons.smartphone,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah Mempunyai Akun? ",
                        style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Sign On",
                          style: TextStyle(
                            color: Colors.blue[200],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign Up', 
                          style: TextStyle(color: Colors.white),
                          // style: GoogleFonts.balooBhai2(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Text(_message, style: TextStyle(color: Colors.red))  
                ],                
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        maxLength: maxLength,
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          hintText: hintText,
          
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

}