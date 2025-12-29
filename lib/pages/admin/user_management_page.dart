import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Box<User> _userBox;
  String _searchQuery = '';
  String _sortBy = 'username'; // username, role

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<User>('users');
  }

  List<User> _getFilteredUsers() {
    var users = _userBox.values.toList();

    if (_searchQuery.isNotEmpty) {
      users = users.where((u) =>
          u.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.role.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    users.sort((a, b) {
      if (_sortBy == 'role') return a.role.compareTo(b.role);
      return a.username.compareTo(b.username);
    });

    return users;
  }

  void _addOrEditUser({User? existingUser, int? index}) {
    final usernameController = TextEditingController(text: existingUser?.username ?? '');
    final passwordController = TextEditingController(text: existingUser?.password ?? '');
    String role = existingUser?.role ?? 'user';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingUser == null ? 'Add User' : 'Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
             const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: ['admin', 'user']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setState(() => role = val ?? 'user'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              final password = passwordController.text.trim();
              if (username.isNotEmpty && password.isNotEmpty) {
                final newUser = User(username: username, password: password, role: role);
                if (existingUser == null) {
                  _userBox.add(newUser);
                } else if (index != null) {
                  _userBox.putAt(index, newUser);
                }
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(existingUser == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(int index) {
    _userBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(Icons.sort),
                    underline: Container(),
                    onChanged: (val) => setState(() => _sortBy = val!),
                    items: const [
                      DropdownMenuItem(value: 'username', child: Text('Name')),
                      DropdownMenuItem(value: 'role', child: Text('Role')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _addOrEditUser(),
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(child: Text('No users found', style: TextStyle(color: Colors.grey)))
              : isDesktop
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
                            columns: const [
                              DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(filteredUsers.length, (index) {
                              final user = filteredUsers[index];
                              // Find actual key in box if needed, but for now we iterate filtered list 
                              // NOTE: Editing requires original index or key. For simplicity, we'll try to find it.
                              // Ideally we store keys. But Hive indices change if we delete. 
                              // Let's rely on finding the object in the box values? 
                              // Actually, Hive lists behave like arrays. 
                              // Let's just use the index from the filtered list mapped back to box index effectively? 
                              // No, filtering breaks index mapping.
                              // Better approach: Store key or use `key` property if extending HiveObject.
                              // Our models don't extend HiveObject. 
                              // Workaround: We'll iterate the box to find the key/index.
                              // Or better: Let's pass the object for Edit, but for Update we need index/key.
                              // Let's assume unique usernames for now or just find index in box.
                              int boxIndex = _userBox.values.toList().indexOf(user);
                              
                              return DataRow(cells: [
                                DataCell(Row(children: [
                                  CircleAvatar(child: Text(user.username[0].toUpperCase()), maxRadius: 16),
                                  SizedBox(width: 8),
                                  Text(user.username),
                                ])),
                                DataCell(Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: user.role == 'admin' ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(user.role.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: user.role == 'admin' ? Colors.purple : Colors.blue)),
                                )),
                                DataCell(Row(children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _addOrEditUser(existingUser: user, index: boxIndex)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(boxIndex)),
                                ])),
                              ]);
                            }),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        int boxIndex = _userBox.values.toList().indexOf(user);
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Text(user.username[0].toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor)),
                            ),
                            title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(user.role.toUpperCase(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            trailing: PopupMenuButton(
                              itemBuilder: (ctx) => [
                                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                              ],
                              onSelected: (val) {
                                if (val == 'edit') _addOrEditUser(existingUser: user, index: boxIndex);
                                if (val == 'delete') _deleteUser(boxIndex);
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
