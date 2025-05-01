import 'package:flutter/material.dart';
import 'package:foundita/models/found_item.dart';
import 'package:foundita/services/usermanagement_service.dart';
import 'package:foundita/widgets/image_widget.dart';
import 'package:intl/intl.dart';
import 'package:foundita/models/user.dart'; // Import User model

class FoundItemDetailsScreen extends StatefulWidget {
  final FoundItem item;

  const FoundItemDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<FoundItemDetailsScreen> createState() => _FoundItemDetailsScreenState();
}

class _FoundItemDetailsScreenState extends State<FoundItemDetailsScreen> {
  final UserManagementService _userService = UserManagementService();
  User? _reporter;
  bool _isLoadingUser = true;
  String? _userError;

  @override
  void initState() {
    super.initState();
    _fetchReporterDetails();
  }

  Future<void> _fetchReporterDetails() async {
    setState(() {
      _isLoadingUser = true;
      _userError = null;
    });
    try {
      final user = await _userService.getUserById(widget.item.userId);
      setState(() {
        _reporter = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _userError = 'Failed to load reporter details: $e';
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.item.itemName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            if (widget.item.photo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ImageFromBackend(blobName: widget.item.photo, fit: BoxFit.cover),
                ),
              ),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Category:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.type.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Color:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(widget.item.color, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Found Date:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item.foundDate),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Reported Date:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item.date),
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              'Reporter:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_isLoadingUser)
              const CircularProgressIndicator()
            else if (_userError != null)
              Text(_userError!, style: TextStyle(color: Colors.red))
            else if (_reporter != null && _reporter!.name != null) // Assuming your User model has a 'name' property
              Text(_reporter!.name!, style: Theme.of(context).textTheme.bodyLarge)
            else
              Text('Reporter information not available', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}