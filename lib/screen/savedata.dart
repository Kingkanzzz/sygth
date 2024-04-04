import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sygth/homepage/homepage.dart';

class SaveData extends StatefulWidget {
  const SaveData({Key? key}) : super(key: key);

  @override
  State<SaveData> createState() => _SaveDataState();
}

class _SaveDataState extends State<SaveData> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _quantityCalController = TextEditingController();
  String? _selectedSupplier;
  String? _selectedPartNo;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2024, 1, 1),
        firstDate: DateTime(2024, 1, 1),
        lastDate: DateTime(DateTime.now().year + 10));
    if (picked != null)
      setState(() {
        _dateController.text = "${picked.day}/ ${picked.month}/ ${picked.year}";
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Data', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    prefixIcon: IconButton(icon: Icon(Icons.calendar_month_outlined,size: 34,),
                    onPressed: () => _selectDate(context),)
                    // suffixIcon: IconButton(
                    //   icon: Icon(Icons.calendar_today),
                    //   onPressed: () => _selectDate(context),
                    // ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSupplier,
              hint: Text('Supplier'),
              onChanged: (value) {
                setState(() {
                  _selectedSupplier = value!;
                });
              },
              items: ['KC RUBBER', 'TMT', 'VINLY BASE']
                  .map((supplier) => DropdownMenuItem<String>(
                        child: Text(supplier),
                        value: supplier,
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('component')
                  .orderBy('Part No')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final partNos = snapshot.data!.docs
                    .map((doc) => doc['Part No'] as String)
                    .toList();
                partNos.sort();
                return DropdownButtonFormField<String>(
                  value: _selectedPartNo,
                  hint: Text('Part No'),
                  onChanged: (value) {
                    setState(() {
                      _selectedPartNo = value!;
                    });
                  },
                  items: partNos
                      .map((partNo) => DropdownMenuItem<String>(
                            child: Text(partNo),
                            value: partNo,
                          ))
                      .toList(),
                );
              },
            ),
            // SizedBox(height: 10),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity(KG)',
              ),
            ),
            TextFormField(
              controller: _quantityCalController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Calculated quantity per pack(KG)',
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    _saveData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue[900],
                  ),
                  child: Text('Save',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() async {
    if (_dateController.text.isEmpty ||
        _selectedSupplier!.isEmpty ||
        _selectedPartNo == null ||
        _quantityController.text.isEmpty ||
        _quantityCalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('save-data').add({
        'Date': _dateController.text,
        'Supplier': _selectedSupplier,
        'Part No': _selectedPartNo,
        'Quantity(KG)': int.parse(_quantityController.text),
        'Calculated quantity per pack(KG)':
            double.parse(_quantityCalController.text)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data saved successfully'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save data: $error'),
        ),
      );
    }
  }
}
