import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/notification_preference_model.dart';
import '../../services/notification_preference_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/batch_control_widget.dart';
import './widgets/preference_section_widget.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final _service = NotificationPreferenceService();
  List<NotificationPreferenceModel> _preferences = [];
  Map<String, List<NotificationPreferenceModel>> _groupedPreferences = {};
  bool _isLoading = true;
  bool _isSaving = false;
  final Set<String> _loadingPreferences = {};
  String? _errorMessage;
  RealtimeChannel? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _realtimeSubscription?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    final userId = _service.currentUserId;
    if (userId == null) return;

    _realtimeSubscription = _service.subscribeToPreferenceChanges(
      userId: userId,
      onUpdate: _handleRealtimeUpdate,
    );
  }

  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType.toString();
      final newData = payload.newRecord;
      final oldData = payload.oldRecord;

      if (eventType == 'PostgresChangeEvent.update' && newData.isNotEmpty) {
        final updatedPreference = NotificationPreferenceModel.fromJson(newData);

        setState(() {
          final index = _preferences.indexWhere(
            (p) => p.id == updatedPreference.id,
          );

          if (index != -1) {
            _preferences[index] = updatedPreference;
            _groupedPreferences = _service.groupPreferencesByCategory(
              _preferences,
            );
          }
        });

        _showRealtimeSyncSnackBar('Preferences synced from another device');
      } else if (eventType == 'PostgresChangeEvent.insert' &&
          newData.isNotEmpty) {
        final newPreference = NotificationPreferenceModel.fromJson(newData);

        setState(() {
          _preferences.add(newPreference);
          _groupedPreferences = _service.groupPreferencesByCategory(
            _preferences,
          );
        });
      }
    } catch (e) {
      debugPrint('Error handling realtime update: $e');
    }
  }

  void _showRealtimeSyncSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.sync, color: Colors.white, size: 18.sp),
            SizedBox(width: 3.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await _service.getUserPreferences();
      final grouped = _service.groupPreferencesByCategory(prefs);

      setState(() {
        _preferences = prefs;
        _groupedPreferences = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePreference(
    NotificationPreferenceModel preference,
    bool newValue,
  ) async {
    setState(() => _loadingPreferences.add(preference.id));

    try {
      final updated = await _service.togglePreference(preference.id, newValue);

      setState(() {
        final index = _preferences.indexWhere((p) => p.id == preference.id);
        if (index != -1) {
          _preferences[index] = updated;
          _groupedPreferences = _service.groupPreferencesByCategory(
            _preferences,
          );
        }
        _loadingPreferences.remove(preference.id);
      });

      _showSuccessSnackBar('Preference updated successfully');
    } catch (e) {
      setState(() => _loadingPreferences.remove(preference.id));
      _showErrorSnackBar('Failed to update preference: $e');
    }
  }

  Future<void> _enableAllNotifications() async {
    final confirm = await _showConfirmDialog(
      'Enable All Notifications',
      'Are you sure you want to enable all notification types?',
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      await _service.enableAllNotifications();
      await _loadPreferences();
      _showSuccessSnackBar('All notifications enabled');
    } catch (e) {
      _showErrorSnackBar('Failed to enable notifications: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _disableAllNotifications() async {
    final confirm = await _showConfirmDialog(
      'Disable All Notifications',
      'Are you sure you want to disable all notification types? You will not receive any alerts.',
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      await _service.disableAllNotifications();
      await _loadPreferences();
      _showSuccessSnackBar('All notifications disabled');
    } catch (e) {
      _showErrorSnackBar('Failed to disable notifications: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 3.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: 3.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.standard,
        title: 'Notification Preferences',
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 30.sp,
                          color: Colors.red.shade400,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Failed to load preferences',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),
                        ElevatedButton.icon(
                          onPressed: _loadPreferences,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPreferences,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BatchControlWidget(
                          onEnableAll: _enableAllNotifications,
                          onDisableAll: _disableAllNotifications,
                          isLoading: _isSaving,
                        ),
                        SizedBox(height: 3.h),
                        PreferenceSectionWidget(
                          title: 'Booking Notifications',
                          icon: Icons.event_note,
                          preferences:
                              _groupedPreferences['Booking Notifications'] ??
                                  [],
                          onToggle: _togglePreference,
                          loadingPreferences: _loadingPreferences,
                        ),
                        PreferenceSectionWidget(
                          title: 'Payment Notifications',
                          icon: Icons.payment,
                          preferences:
                              _groupedPreferences['Payment Notifications'] ??
                                  [],
                          onToggle: _togglePreference,
                          loadingPreferences: _loadingPreferences,
                        ),
                        PreferenceSectionWidget(
                          title: 'Driver Communication',
                          icon: Icons.directions_car,
                          preferences:
                              _groupedPreferences['Driver Communication'] ?? [],
                          onToggle: _togglePreference,
                          loadingPreferences: _loadingPreferences,
                        ),
                        PreferenceSectionWidget(
                          title: 'Marketing & Updates',
                          icon: Icons.campaign,
                          preferences:
                              _groupedPreferences['Marketing & Updates'] ?? [],
                          onToggle: _togglePreference,
                          loadingPreferences: _loadingPreferences,
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20.sp,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  'Changes are saved automatically. You can update preferences anytime.',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
