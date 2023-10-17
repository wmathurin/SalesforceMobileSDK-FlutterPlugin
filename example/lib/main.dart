import 'package:flutter/material.dart';
import 'package:salesforce/salesforce.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: ContactsPage(),
  ));
}

class ContactsPage extends StatefulWidget {
  @override
  ContactsPageState createState() => new ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {

  @override
  void initState() {
    super.initState();
  }

  Future<List<Contact>?> fetchData() async {
    print("fetchData");
    try {
      //Query test
      final Map response = await SalesforcePlugin.query("SELECT Id, Name, Email FROM Contact LIMIT 1000");
      final List<dynamic> records = response['records'] ?? [];
      final List<Contact> contacts = records.map((record) => Contact(name: record["Name"] ?? "", email: record["Email"]  ?? "")).toList();
      return contacts;
    } on Exception catch (e){
      throw new Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (BuildContext context, AsyncSnapshot<List<Contact>?> snapshot){
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData){
            final List<Contact> _contacts = snapshot.data ?? [];
            return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                itemBuilder: (BuildContext context, int index) => ListTile(
                    title : Text(_contacts[index].name!),
                    subtitle: Text(_contacts[index].email!),
                    leading: CircleAvatar(
                        child: Text(_contacts[index].name![0])
                    )
                ),
                itemCount: _contacts.length
            );
          } else if (snapshot.hasError){
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {});
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class Contact {
  final String? name;
  final String? email;

  const Contact({this.name, this.email});
}
