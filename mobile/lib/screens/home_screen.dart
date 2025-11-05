import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ItemProvider>(context, listen: false);
      provider.checkHealth();
      provider.fetchItems();
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddItemDialog(),
    ).then((result) {
      if (result != null) {
        final provider = Provider.of<ItemProvider>(context, listen: false);
        provider.addItem(result['name'], result['description']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Learn'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ItemProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Health status indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: provider.isHealthy ? Colors.green[100] : Colors.red[100],
                child: Row(
                  children: [
                    Icon(
                      provider.isHealthy ? Icons.check_circle : Icons.error,
                      color: provider.isHealthy ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isHealthy
                          ? 'Backend Connected'
                          : 'Backend Unavailable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: provider.isHealthy ? Colors.green[900] : Colors.red[900],
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (provider.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.red[50],
                  child: Text(
                    provider.error!,
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),

              // Items list
              Expanded(
                child: provider.isLoading && provider.items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No items found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add an item',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => provider.fetchItems(),
                            child: ListView.builder(
                              itemCount: provider.items.length,
                              itemBuilder: (context, index) {
                                final item = provider.items[index];
                                return ItemCard(
                                  item: item,
                                  onDelete: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Item'),
                                        content: Text(
                                            'Are you sure you want to delete "${item.name}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              provider.deleteItem(item.id);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

