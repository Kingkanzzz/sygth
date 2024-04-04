import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sygth/screen/savedata.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Component List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.description_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SaveData()));
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('component')
            .orderBy('Part No')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Column(
                children: [
                  ListTile(
                    title: Text(data['Part No'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${data['Description']}',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                        Text('Part Wgt(g): ${data['Part Wgt(g)']}',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => Detail(data))));
                    },
                  ),
                  Divider(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class Detail extends StatefulWidget {
  final Map<String, dynamic> data;

  Detail(this.data);

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  double inputValue = 0.0;
  double result = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.data['Part No'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            // SizedBox(height: 10),
            Text(
              'Description: ${widget.data['Description']}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Part Wgt(g): ${widget.data['Part Wgt(g)']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter value',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    inputValue = 0;
                  } else {
                    inputValue = double.parse(value);
                  }
                });
              },
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (inputValue != null && inputValue != 0) {
                      double partWgt = double.parse(widget.data['Part Wgt(g)']);
                      result = inputValue * (partWgt / 1000);
                    } else {
                      result = 0.0;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                ),
                child: Text('Calculate',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            Text('Result: ${result.toStringAsFixed(2)} KG',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
