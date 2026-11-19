import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

const supabaseUrl = 'https://czrldssmxtodfiepqvdo.supabase.co';
const supabasePublishableKey = 'sb_publishable_5UcygNmws5DnX9RDXy3_Dg_9V3qUdWk';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const ProviderScope(child: RiffsApp()));
}
