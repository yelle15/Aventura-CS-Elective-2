import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';

const supabaseUrl = 'https://cbctnaoiyrzjrknexmrj.supabase.co';
const supabasePublishableKey = 'sb_publishable_5m58YXrTCfKkyisvP6whyg_al5yZZ3Q';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..initialize(),
        ),
      ],
      child: const RiftsApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
