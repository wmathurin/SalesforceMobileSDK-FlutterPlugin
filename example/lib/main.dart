import 'package:flutter/material.dart';
import 'package:sfplugin/sfplugin.dart';

class Contact {
  final String name;
  final String email;

  const Contact({this.name, this.email});
}

class ContactListItem extends ListTile {

  ContactListItem(Contact contact) :
        super(
          title : new Text(contact.name),
          subtitle: new Text(contact.email),
          leading: new CircleAvatar(
              child: new Text(contact.name[0])
          )
      );

}

class ContactList extends StatelessWidget {

  final List<Contact> contacts;

  ContactList(this.contacts);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (BuildContext context, int index) => new ContactListItem(contacts[index]),
        itemCount: contacts.length
    );
  }

}

class ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts;

  @override
  void initState() {
    super.initState();
    setState(() => this.contacts = []);
    fetchData(); // asynchronous
  }

  void fetchData() async {

    try {
      //Query test
      Map response = await SalesforcePlugin.query("SELECT Id, Name, Email FROM Contact LIMIT 10000");
      final List<dynamic> records = response['records'] ?? [];
      final List<Contact> contacts = records.map((record) => new Contact(name: record["Name"] ?? "", email: record["Email"]  ?? "")).toList();
      print('results: ${contacts.length}');
      if (mounted) {
        setState(() => this.contacts = contacts);
      }

    } on Exception catch (e){
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Contacts"),
          actions: [
            IconButton(
              icon: Text("${this.contacts.length}"),
              onPressed: null,
            ),
          ],
        ),
        body: new ContactList(this.contacts),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() => this.contacts = []);
            fetchData(); // asynchronous
          },
          child: Icon(Icons.refresh),
        ),
    );
  }
}

class ContactsPage extends StatefulWidget {

  @override
  ContactsPageState createState() => new ContactsPageState();

}

void main() {
  runApp(
      new MaterialApp(
          title: 'Flutter Demo',
          theme: new ThemeData(
              primarySwatch: Colors.blue
          ),
          home: new ContactsPage(),
      )
  );
}
