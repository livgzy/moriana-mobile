import 'package:firebase_auth/firebase_auth.dart';
import 'package:moriana_mobile/admin/main_page.dart';
import 'package:moriana_mobile/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';
// import 'package:moriana_mobile/menu_image_loader.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:moriana_mobile/providers/navigation_provider.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'login.dart';
import 'main_page.dart';
import 'package:provider/provider.dart';
import 'providers/user_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://pvnwbduccmfnttlhyxuo.supabase.co',
    anonKey: 'sb_publishable_0JBko4HLSeekwGdytqtzwQ_KJhj_UY8',
  );
  // await MenuImageLoader.insertAllMenuImages();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

      ],
      child : MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (authSnap.data == null) {
              return const LoginScreen();
            }

            final userProvider = Provider.of<UserProvider>(context, listen: false);

            return FutureBuilder(
              future: userProvider.loadUser(), 
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userProvider.isAdmin) {
                  return const AdminMainScreen();
                } else {
                  return const MainScreen();
                }
              },
            );
          },
        ),

      ),
    );
  }
}