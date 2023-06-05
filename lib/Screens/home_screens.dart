import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:min_gram/Screens/chat_screens.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' hide Text;

import '../services/telegram_service.dart';

//get Contacts
Future<List<int>> getContacts(BuildContext context) async {
  final telegramService = Provider.of<TelegramService>(context, listen: false);
  const searchQuery = GetContacts();
  final result = await telegramService.send(searchQuery);
  print("tesst contact ${jsonEncode(result)}");

  if (result is Users) {
    final user = result.userIds;
    return user;
  } else {
    if (kDebugMode) {
      print("Khong lay duoc contact");
    }
    return [];
  }
}

class HomeScreens extends StatefulWidget {
  const HomeScreens({Key? key}) : super(key: key);

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  List<int> contacts = [];
  List<User> users = [];

  final _phoneNumberController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listContact();
  }

  void listContact() async {
    contacts = await getContacts(context);
    getUserInfoForContacts();
  }

  void getUserInfoForContacts() async {
    final telegramService =
        Provider.of<TelegramService>(context, listen: false);

    for (final userId in contacts) {
      final getUserQuery = GetUser(userId: userId);
      final result = await telegramService.send(getUserQuery);
      print("user: ${jsonEncode(result)}");
      if (result is User) {
        setState(() {
          users.add(result);
        });
      } else {
        if (kDebugMode) {
          print('Failed to get user info for user ID: $userId');
        }
      }
    }
  }

  void addContact(BuildContext context) async {
    final telegramService =
        Provider.of<TelegramService>(context, listen: false);

    final phoneNumber = _phoneNumberController.text.trim();
    final firstName = _nameController.text.trim();

    if (phoneNumber.isNotEmpty && firstName.isNotEmpty) {
      final contact = Contact(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: '',
        userId: 0,
        vcard: '',
      );
      List<Contact> contacts = [];
      contacts.add(contact);

      final addContactQuery = ImportContacts(
        contacts: contacts,
      );

      final result = await telegramService.send(addContactQuery);
      print("add ${jsonEncode(result)}");

      if (result is ImportedContacts) {
        // Người dùng đã được thêm thành công vào danh bạ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact added successfully'),
          ),
        );
      } else {
        // Lỗi xảy ra khi thêm người dùng vào danh bạ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add contact'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter phone number and first name'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatScreens(chatId: user.id,)));
              },
              child: ListTile(
                title: Text(user.firstName ?? 'k co'),
                subtitle: Text(user.username ?? 'k co'),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('ADD CONTACT'),
                  content: Column(
                    children: [
                      TextField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        addContact(context);
                      },
                      child: const Text('Add Contact'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add_circle_outline),
        ));
  }
}
