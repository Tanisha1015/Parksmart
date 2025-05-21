// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return const Center(
        child: Text('User not logged in'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // Profile picture
          CircleAvatar(
            radius: 60,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Text(
                    user.displayName?.substring(0, 1) ?? 'U',
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          
          const SizedBox(height: 20),
          
          // User name
          Text(
            user.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // User email
          Text(
            user.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Profile options
          _buildProfileOption(
            context,
            icon: Icons.person,
            title: 'Account Information',
            onTap: () {
              // Navigate to account info screen
            },
          ),
          
          _buildProfileOption(
            context,
            icon: Icons.car_rental,
            title: 'Vehicle Information',
            onTap: () {
              // Navigate to vehicle info screen
            },
          ),
          
          _buildProfileOption(
            context,
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () {
              // Navigate to payment methods screen
            },
          ),
          
          _buildProfileOption(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              // Navigate to settings screen
            },
          ),
          
          _buildProfileOption(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help & support screen
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
