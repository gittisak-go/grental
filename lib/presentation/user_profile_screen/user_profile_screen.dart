import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/payment_card_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_menu_item_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/toggle_menu_item_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _biometricEnabled = false;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "phone": "+1 (555) 123-4567",
    "membershipStatus": "Premium Member",
    "profileImage": "assets/images/sarah_johnson_profile.png",
    "emergencyContacts": [
      {
        "name": "John Johnson",
        "phone": "+1 (555) 987-6543",
        "relation": "Spouse"
      },
      {
        "name": "Emily Johnson",
        "phone": "+1 (555) 456-7890",
        "relation": "Sister"
      }
    ],
    "paymentMethods": [
      {"type": "Visa", "lastFour": "4532", "isDefault": true},
      {"type": "Mastercard", "lastFour": "8901", "isDefault": false},
      {"type": "American Express", "lastFour": "2345", "isDefault": false}
    ],
    "preferences": {
      "vehicleType": "Comfort",
      "autoTip": "15%",
      "pickupInstructions": "Please call when you arrive"
    }
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 5.w,
          ),
        ),
        title: Text(
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: CustomIconWidget(
              iconName: 'edit',
              color: theme.colorScheme.primary,
              size: 5.w,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Profile Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ProfileHeaderWidget(
                userName: _userData["name"] as String,
                userEmail: _userData["email"] as String,
                membershipStatus: _userData["membershipStatus"] as String,
                profileImageUrl: _userData["profileImage"] as String,
                onEditProfile: _showEditProfileDialog,
              ),
            ),

            SizedBox(height: 4.h),

            // Personal Information Section
            ProfileSectionWidget(
              title: 'Personal Information',
              children: [
                ProfileMenuItemWidget(
                  icon: 'person',
                  title: 'Edit Profile',
                  subtitle: 'Update your personal details',
                  onTap: _showEditProfileDialog,
                ),
                ProfileMenuItemWidget(
                  icon: 'phone',
                  title: 'Phone Number',
                  subtitle: _userData["phone"] as String,
                  onTap: _showPhoneEditDialog,
                ),
                ProfileMenuItemWidget(
                  icon: 'email',
                  title: 'Email Address',
                  subtitle: _userData["email"] as String,
                  onTap: _showEmailEditDialog,
                ),
              ],
            ),

            // Preferences Section
            ProfileSectionWidget(
              title: 'Preferences',
              children: [
                ToggleMenuItemWidget(
                  icon: 'dark_mode',
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark themes',
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    HapticFeedback.lightImpact();
                  },
                ),
                ToggleMenuItemWidget(
                  icon: 'notifications',
                  title: 'Push Notifications',
                  subtitle: 'Receive ride updates and promotions',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    HapticFeedback.lightImpact();
                  },
                ),
                ToggleMenuItemWidget(
                  icon: 'location_on',
                  title: 'Location Services',
                  subtitle: 'Allow location access for better service',
                  value: _locationEnabled,
                  onChanged: (value) {
                    setState(() => _locationEnabled = value);
                    HapticFeedback.lightImpact();
                  },
                ),
                ProfileMenuItemWidget(
                  icon: 'language',
                  title: 'Language',
                  subtitle: 'English (US)',
                  onTap: _showLanguageDialog,
                ),
              ],
            ),

            // Payment Methods Section
            ProfileSectionWidget(
              title: 'Payment Methods',
              showDivider: false,
              children: [
                ...((_userData["paymentMethods"] as List)
                    .map((card) => PaymentCardWidget(
                          cardType: card["type"] as String,
                          lastFourDigits: card["lastFour"] as String,
                          isDefault: card["isDefault"] as bool,
                          onTap: () => _showCardDetailsDialog(card),
                          onDelete: () => _showDeleteCardDialog(card),
                        ))
                    .toList()),
                ProfileMenuItemWidget(
                  icon: 'add',
                  title: 'Add Payment Method',
                  subtitle: 'Add a new card or payment option',
                  onTap: _showAddPaymentDialog,
                  iconColor: theme.colorScheme.primary,
                ),
              ],
            ),

            // Ride Preferences Section
            ProfileSectionWidget(
              title: 'Ride Preferences',
              children: [
                ProfileMenuItemWidget(
                  icon: 'directions_car',
                  title: 'Default Vehicle Type',
                  subtitle: (_userData["preferences"] as Map)["vehicleType"]
                      as String,
                  onTap: _showVehicleTypeDialog,
                ),
                ProfileMenuItemWidget(
                  icon: 'attach_money',
                  title: 'Automatic Tip',
                  subtitle:
                      (_userData["preferences"] as Map)["autoTip"] as String,
                  onTap: _showTipDialog,
                ),
                ProfileMenuItemWidget(
                  icon: 'note',
                  title: 'Pickup Instructions',
                  subtitle: (_userData["preferences"]
                      as Map)["pickupInstructions"] as String,
                  onTap: _showInstructionsDialog,
                ),
              ],
            ),

            // Safety Section
            ProfileSectionWidget(
              title: 'Safety & Security',
              children: [
                ProfileMenuItemWidget(
                  icon: 'emergency',
                  title: 'Emergency Contacts',
                  subtitle:
                      '${(_userData["emergencyContacts"] as List).length} contacts added',
                  onTap: _showEmergencyContactsDialog,
                ),
                ToggleMenuItemWidget(
                  icon: 'fingerprint',
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face ID for payments',
                  value: _biometricEnabled,
                  onChanged: (value) {
                    setState(() => _biometricEnabled = value);
                    HapticFeedback.lightImpact();
                  },
                ),
                ProfileMenuItemWidget(
                  icon: 'security',
                  title: 'Privacy Settings',
                  subtitle: 'Manage your data and privacy',
                  onTap: _showPrivacyDialog,
                ),
              ],
            ),

            // Support Section
            ProfileSectionWidget(
              title: 'Support',
              children: [
                ProfileMenuItemWidget(
                  icon: 'help',
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: _showHelpCenter,
                ),
                ProfileMenuItemWidget(
                  icon: 'feedback',
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts with us',
                  onTap: _showFeedbackDialog,
                ),
                ProfileMenuItemWidget(
                  icon: 'info',
                  title: 'About TaxiHouse',
                  subtitle: 'Version 1.0.0',
                  onTap: _showAboutDialog,
                ),
              ],
            ),

            // Account Management Section
            ProfileSectionWidget(
              title: 'Account',
              children: [
                ProfileMenuItemWidget(
                  icon: 'lock',
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: _showChangePasswordDialog,
                ),
                ProfileMenuItemWidget(
                  icon: 'logout',
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: _showLogoutDialog,
                  iconColor: theme.colorScheme.error,
                  showArrow: false,
                ),
                ProfileMenuItemWidget(
                  icon: 'delete_forever',
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  onTap: _showDeleteAccountDialog,
                  iconColor: theme.colorScheme.error,
                  showArrow: false,
                ),
              ],
            ),

            SizedBox(height: 10.h), // Extra space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        variant: CustomBottomBarVariant.standard,
        currentIndex: 3, // Profile tab
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/ride-request-screen',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/live-tracking-screen',
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/ride-history-screen',
                (route) => false,
              );
              break;
            case 3:
              // Already on profile screen
              break;
          }
        },
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text(
            'Profile editing functionality would be implemented here with form fields for name, email, and photo upload.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPhoneEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: const Text(
            'Phone number verification would be implemented here with SMS verification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEmailEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Email Address'),
        content: const Text(
            'Email update functionality would be implemented here with email verification.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English (US)'),
              leading: Radio(value: true, groupValue: true, onChanged: null),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              leading: Radio(value: false, groupValue: true, onChanged: null),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCardDetailsDialog(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${card["type"]} Details'),
        content: Text(
            'Card ending in ${card["lastFour"]}\n\nCard management features would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!(card["isDefault"] as bool))
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: const Text('Set as Default'),
            ),
        ],
      ),
    );
  }

  void _showDeleteCardDialog(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text(
            'Are you sure you want to remove your ${card["type"]} ending in ${card["lastFour"]}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: const Text(
            'Payment method addition would be implemented here with secure card input forms.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _showVehicleTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Vehicle Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Economy'),
              leading: Radio(
                  value: 'Economy', groupValue: 'Comfort', onChanged: null),
            ),
            ListTile(
              title: const Text('Comfort'),
              leading: Radio(
                  value: 'Comfort', groupValue: 'Comfort', onChanged: null),
            ),
            ListTile(
              title: const Text('Premium'),
              leading: Radio(
                  value: 'Premium', groupValue: 'Comfort', onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Automatic Tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('10%'),
              leading: Radio(value: '10%', groupValue: '15%', onChanged: null),
            ),
            ListTile(
              title: const Text('15%'),
              leading: Radio(value: '15%', groupValue: '15%', onChanged: null),
            ),
            ListTile(
              title: const Text('20%'),
              leading: Radio(value: '20%', groupValue: '15%', onChanged: null),
            ),
            ListTile(
              title: const Text('Custom'),
              leading:
                  Radio(value: 'Custom', groupValue: '15%', onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pickup Instructions'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter special pickup instructions...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: (_userData["emergencyContacts"] as List).length,
            itemBuilder: (context, index) {
              final contact = (_userData["emergencyContacts"] as List)[index];
              return ListTile(
                title: Text(contact["name"] as String),
                subtitle: Text('${contact["relation"]} • ${contact["phone"]}'),
                trailing: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: Theme.of(context).colorScheme.error,
                    size: 5.w,
                  ),
                  onPressed: () {},
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text(
            'Privacy and data management settings would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const Text(
            'Help center with FAQ, contact support, and troubleshooting guides would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share your thoughts and suggestions...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About TaxiHouse'),
        content: const Text(
            'TaxiHouse v1.0.0\n\nPremium taxi booking experience with cinematic design.\n\n© 2024 TaxiHouse. All rights reserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content:
            const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/authentication-screen',
                (route) => false,
              );
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
