import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:relate/features/relationship/service/contact_service.dart';
import 'package:relate/features/relationship/bloc/relationship_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/features/relationship/bloc/relationship_bloc.dart';
import 'package:relate/features/relationship/bloc/relationship_event.dart';

class ContactImportPage extends StatefulWidget {
  const ContactImportPage({super.key});

  @override
  State<ContactImportPage> createState() => _ContactImportPageState();
}

class _ContactImportPageState extends State<ContactImportPage> {
  final ContactService _contactService = ContactService();
  List<Contact> _contacts = [];
  final Set<String> _selectedContactIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _contactService.getContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load contacts. Please check permissions.';
        _isLoading = false;
      });
    }
  }

  Future<void> _importSelected() async {
    if (_selectedContactIds.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedContacts =
          _contacts.where((c) => _selectedContactIds.contains(c.id)).toList();

      for (var contact in selectedContacts) {
        // Basic mapping - can be improved
        final firstName = contact.name.first;
        final lastName = contact.name.last;
        final phone =
            contact.phones.isNotEmpty ? contact.phones.first.number : '';

        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          await RelationshipController().createRelationship(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phone,
            // Add other fields as needed
          );
        }
      }

      if (mounted) {
        context.read<RelationshipListBloc>().add(LoadRelationships());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${selectedContacts.length} contacts imported')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing contacts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Contacts'),
        actions: [
          if (!_isLoading && _contacts.isNotEmpty)
            TextButton(
              onPressed:
                  _selectedContactIds.isNotEmpty ? _importSelected : null,
              child: Text(
                'Import (${_selectedContactIds.length})',
                style: TextStyle(
                  color: _selectedContactIds.isNotEmpty
                      ? Colors.blue
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContacts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_contacts.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }

    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final isSelected = _selectedContactIds.contains(contact.id);
        final hasPhone = contact.phones.isNotEmpty;
        final phone = hasPhone ? contact.phones.first.number : 'No phone';

        return CheckboxListTile(
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedContactIds.add(contact.id);
              } else {
                _selectedContactIds.remove(contact.id);
              }
            });
          },
          title: Text(contact.displayName),
          subtitle: Text(phone),
          secondary: contact.photo != null
              ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
              : CircleAvatar(
                  child: Text(contact.displayName.isNotEmpty
                      ? contact.displayName[0]
                      : '?')),
        );
      },
    );
  }
}
