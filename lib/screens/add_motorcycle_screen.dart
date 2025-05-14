import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMotorcycleScreen extends StatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  State<AddMotorcycleScreen> createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends State<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, List<String>> motorcycleData = {
    'Honda': ['CB500F', 'Click 125i', 'TMX Supremo', 'ADV 160', 'BeAT', 'PCX160'],
    'Yamaha': ['Mio i125', 'NMAX', 'Sniper 155', 'Aerox 155', 'FZi'],
    'Suzuki': ['Raider R150', 'Burgman Street', 'Gixxer SF', 'Skydrive Sport', 'V-Strom 250 SX'],
    'Kawasaki': ['Barako II', 'Rouser NS160', 'Z400', 'Dominar 400', 'W175'],
    'KTM': ['Duke 200', 'RC 390', 'Adventure 250', '390 Adventure'],
    'Rusi': ['Flash 150', 'Classic 250', 'Koso 150'],
    'Motorstar': ['Café 400', 'Xplorer Z200', 'MSX 150'],
  };

  String? selectedBrand;
  String? selectedModel;
  bool isCustomBrand = false;
  bool isCustomModel = false;

  final TextEditingController _customBrandCtrl = TextEditingController();
  final TextEditingController _customModelCtrl = TextEditingController();
  final TextEditingController _yearCtrl = TextEditingController();
  final TextEditingController _plateCtrl = TextEditingController();
  final TextEditingController _nicknameCtrl = TextEditingController();

  @override
  void dispose() {
    _customBrandCtrl.dispose();
    _customModelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveMotorcycle() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add a motorcycle.')),
      );
      return;
    }

    final brandToSave = isCustomBrand
        ? _customBrandCtrl.text.trim()
        : selectedBrand;
    final modelToSave = isCustomModel || isCustomBrand
        ? _customModelCtrl.text.trim()
        : selectedModel;
    final yearToSave = int.tryParse(_yearCtrl.text.trim());
    final plateToSave = _plateCtrl.text.trim();
    final nicknameToSave = _nicknameCtrl.text.trim();

    if (brandToSave == null || modelToSave == null ||
        brandToSave.isEmpty || modelToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter brand and model.')),
      );
      return;
    }

    final response = await supabase.from('motorcycles').insert({
      'user_id': user.id,
      'brand': brandToSave,
      'model': modelToSave,
      'year': yearToSave,
      'plate': plateToSave,
      'nickname': nicknameToSave,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error!.message}')),
      );
    } else {
      // Show success dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Motorcycle saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Motorcycle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Motorcycle Brand"),
              DropdownButton<String>(
                value: selectedBrand,
                hint: const Text("Select Brand"),
                isExpanded: true,
                items: [
                  ...motorcycleData.keys.map((brand) => DropdownMenuItem(
                        value: brand,
                        child: Text(brand),
                      )),
                  const DropdownMenuItem(
                    value: "Other",
                    child: Text("Other (Enter manually)"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedBrand = value;
                    selectedModel = null;
                    isCustomBrand = value == "Other";
                  });
                },
              ),
              if (isCustomBrand)
                TextField(
                  controller: _customBrandCtrl,
                  decoration: const InputDecoration(labelText: 'Enter Brand'),
                ),
              const SizedBox(height: 16),
              const Text("Motorcycle Model"),
              if (selectedBrand != null && selectedBrand != "Other")
                DropdownButton<String>(
                  value: selectedModel,
                  hint: const Text("Select Model"),
                  isExpanded: true,
                  items: [
                    ...?motorcycleData[selectedBrand]?.map((model) => DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        )),
                    const DropdownMenuItem(
                      value: "Other",
                      child: Text("Other (Enter manually)"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedModel = value;
                      isCustomModel = value == "Other";
                    });
                  },
                ),
              if (isCustomModel || isCustomBrand)
                TextField(
                  controller: _customModelCtrl,
                  decoration: const InputDecoration(labelText: 'Enter Model'),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateCtrl,
                decoration: const InputDecoration(labelText: 'Plate Number'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameCtrl,
                decoration: const InputDecoration(labelText: 'Nickname (optional)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMotorcycle,
                child: const Text('Save Motorcycle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
