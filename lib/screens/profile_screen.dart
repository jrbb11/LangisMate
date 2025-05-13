import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      // .maybeSingle() returns your row as a Map or null if none found
      final data = await supabase
          .from('user_profiles')
          .select('first_name,last_name,phone,address,nickname,photo_url')
          .eq('user_id', user.id)
          .maybeSingle()
        as Map<String, dynamic>?;  // a PostgrestMap under the hood

      if (data != null) {
        _profile = data;
      } else {
        debugPrint('No profile found for user ${user.id}');
      }
    } on PostgrestException catch (e) {
      // handle Supabase errors here
      debugPrint('Supabase error loading profile: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error loading profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return const Scaffold(body: Center(child: Text('No profile found')));
    }

    final fn   = _profile!['first_name'] ?? '';
    final ln   = _profile!['last_name']  ?? '';
    final nick = _profile!['nickname']   ?? '';
    final phone= _profile!['phone']      ?? '';
    final addr = _profile!['address']    ?? '';
    final photo= _profile!['photo_url']  as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: photo != null ? NetworkImage(photo) : null,
              child: photo == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 16),
            Text('$fn $ln', style: Theme.of(context).textTheme.headlineSmall),
            if (nick.isNotEmpty) Text('“$nick”'),
            const SizedBox(height: 8),
            Text(phone),
            Text(addr),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () => Navigator.pushNamed(context, '/edit_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
