// lib/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker       = ImagePicker();
  XFile? _pickedImage;

  final _formKey                  = GlobalKey<FormState>();
  final _firstNameCtrl            = TextEditingController();
  final _lastNameCtrl             = TextEditingController();
  final _emailCtrl                = TextEditingController();
  final _phoneCtrl                = TextEditingController();
  final _addressCtrl              = TextEditingController();
  final _nicknameCtrl             = TextEditingController();
  final _photoUrlCtrl             = TextEditingController();

  bool _loading       = true;
  bool _saving        = false;
  bool _editingEmail  = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _addressCtrl,
      _nicknameCtrl,
      _photoUrlCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final supabase = Supabase.instance.client;
    final user     = supabase.auth.currentUser;
    if (user == null) return setState(() => _loading = false);

    try {
      final row = await supabase
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .single() as Map<String, dynamic>;

      _firstNameCtrl.text = row['first_name'] ?? '';
      _lastNameCtrl.text  = row['last_name']  ?? '';
      _emailCtrl.text     = row['email']      ?? '';
      _phoneCtrl.text     = row['phone']      ?? '';
      _addressCtrl.text   = row['address']    ?? '';
      _nicknameCtrl.text  = row['nickname']   ?? '';
      _photoUrlCtrl.text  = row['photo_url']  ?? '';
    } on PostgrestException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load failed: ${err.message}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      keyboardType: type,
      validator: validator,
    );
  }

  Widget _buildEmailField() {
    return Row(
      children: [
        Expanded(
          child: _editingEmail
              ? TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                )
              : TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: true,
                  style: TextStyle(color: Colors.grey[700]),
                ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            setState(() {
              if (_editingEmail) {
                // cancel: reload original email
                _loadProfile();
              }
              _editingEmail = !_editingEmail;
            });
          },
          child: Text(_editingEmail ? 'Cancel' : 'Change'),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final supabase = Supabase.instance.client;
    final user     = supabase.auth.currentUser;
    if (user == null) return setState(() => _saving = false);

    try {
      String photoUrl = _photoUrlCtrl.text.trim();

      // 1️⃣ upload new image if picked
      if (_pickedImage != null) {
        final file = File(_pickedImage!.path);
        final ext  = p.extension(file.path);
        final key  = 'profiles/${user.id}$ext';

        await supabase.storage
            .from('profile-photos')
            .upload(key, file, fileOptions: const FileOptions(upsert: true));

        photoUrl = supabase.storage.from('profile-photos').getPublicUrl(key);
      }

      // 2️⃣ handle email change
      if (_editingEmail) {
        // this will throw AuthException on error
        await supabase.auth.updateUser(
          UserAttributes(email: _emailCtrl.text.trim()),
        );
        _editingEmail = false;
      }

      // 3️⃣ update profile table
      await supabase
        .from('user_profiles')
        .update({
          'first_name': _firstNameCtrl.text.trim(),
          'last_name':  _lastNameCtrl.text.trim(),
          'email':      _emailCtrl.text.trim(),
          'phone':      _phoneCtrl.text.trim(),
          'address':    _addressCtrl.text.trim(),
          'nickname':   _nicknameCtrl.text.trim(),
          'photo_url':  photoUrl,
        })
        .eq('user_id', user.id);

      _photoUrlCtrl.text = photoUrl;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } on AuthException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email change failed: ${err.message}')),
      );
    } on PostgrestException catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: ${err.message}')),
      );
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $err')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatar = _pickedImage != null
        ? FileImage(File(_pickedImage!.path))
        : (_photoUrlCtrl.text.isNotEmpty
            ? NetworkImage(_photoUrlCtrl.text)
            : const AssetImage('assets/avatar_placeholder.png'))
            as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // avatar + change photo
            CircleAvatar(radius: 50, backgroundImage: avatar),
            TextButton(onPressed: _pickImage, child: const Text('Change Photo')),
            const SizedBox(height: 24),

            // form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // first + last
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          'First Name',
                          _firstNameCtrl,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Enter first name' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          'Last Name',
                          _lastNameCtrl,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Enter last name' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // email
                  _buildEmailField(),
                  const SizedBox(height: 16),

                  // phone
                  _buildField(
                    'Phone',
                    _phoneCtrl,
                    type: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter phone number' : null,
                  ),
                  const SizedBox(height: 16),

                  // address
                  _buildField(
                    'Address',
                    _addressCtrl,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter address' : null,
                  ),
                  const SizedBox(height: 16),

                  // nickname
                  _buildField(
                    'Nickname',
                    _nicknameCtrl,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter nickname' : null,
                  ),
                  const SizedBox(height: 24),

                  _saving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Save Changes'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
