# Debug Drives API Issue - Step by Step Guide

## Problem: API not being hit when tapping on drives in TPO role

## 🔍 Debug Steps

### 1. Run the App and Check Console Logs

When you navigate to the Drives tab, you should see these logs in order:

```
🎯 DrivesScreen.initState() called
🔔 Calling DrivesViewModel.fetchDrives() from initState
🚀 DrivesViewModel.fetchDrives() called
📡 Calling API: _tpo.getDrives()
📦 API Response: isSuccess=true/false, data=[...]/null
✅ Successfully loaded X drives OR ❌ API Error: message
🏁 fetchDrives() completed
📱 DrivesScreen.build() called - isLoading: false, drives: X
```

### 2. What Each Log Means

- **🎯 initState()**: Screen is being created (only happens once)
- **🚀 fetchDrives()**: ViewModel method is called
- **📡 Calling API**: API request is being made
- **📦 API Response**: Server response received
- **✅/❌**: Success or failure status
- **📱 build()**: UI is being rendered

### 3. Common Issues & Solutions

#### Issue 1: No logs appear when clicking Drives tab
**Cause**: IndexedStack keeps all screens in memory, initState only called once
**Solution**: Added `didChangeDependencies()` to refresh when needed

#### Issue 2: API call fails with authentication error
**Cause**: User not logged in or token expired
**Solution**: Check if you're properly logged in as TPO

#### Issue 3: API returns success but no data
**Cause**: Backend has no drives or API endpoint issue
**Solution**: Check backend data and API endpoint

#### Issue 4: API call not made at all
**Cause**: Provider not properly set up or context issue
**Solution**: Provider is set up in main.dart, should work

### 4. Manual Refresh

If API doesn't load automatically:
- **Pull to refresh**: Swipe down on the drives list
- You should see: `🔄 Refresh triggered for drives`

### 5. Check These Files

✅ **Fixed Files**:
- `lib/viewmodels/tpo_viewmodels/drives_viewmodel.dart` - Added comprehensive debug logs
- `lib/views/tpo_role/Drives/screens/drive_screen.dart` - Added debug logs and refresh functionality

✅ **Verified Files**:
- `lib/repositories/tpo_repository.dart` - API endpoint correctly configured
- `lib/network/api_endpoints.dart` - Endpoint: `/api/v1/drive`
- `lib/main.dart` - DrivesViewModel provider is set up
- `lib/views/shells/tpo_shell.dart` - DrivesScreen included in IndexedStack

### 6. Expected Console Output

**Working correctly:**
```
🎯 DrivesScreen.initState() called
🔔 Calling DrivesViewModel.fetchDrives() from initState
🚀 DrivesViewModel.fetchDrives() called
📡 Calling API: _tpo.getDrives()
📦 API Response: isSuccess=true, data=[Instance of 'Drive', ...]
✅ Successfully loaded 3 drives
🏁 fetchDrives() completed
📱 DrivesScreen.build() called - isLoading: false, drives: 3
```

**With error:**
```
🎯 DrivesScreen.initState() called
🔔 Calling DrivesViewModel.fetchDrives() from initState
🚀 DrivesViewModel.fetchDrives() called
📡 Calling API: _tpo.getDrives()
📦 API Response: isSuccess=false, data=null
❌ API Error: Authentication failed
💥 Exception in fetchDrives(): Authentication failed
🏁 fetchDrives() completed
📱 DrivesScreen.build() called - isLoading: false, drives: 0
```

### 7. Test Scenarios

1. **First time accessing Drives tab**: Should trigger API call
2. **Switching away and back**: Should show cached data, refresh if empty
3. **Pull to refresh**: Should always trigger API call
4. **Tap on DriveCard**: Should show "DRIVE CARD TAPPED: [company]"

### 8. If Still Not Working

Check:
1. **Network connectivity**: Make sure device has internet
2. **Authentication**: Verify you're logged in as TPO user
3. **Backend status**: Check if backend server is running
4. **API endpoint**: Verify `/api/v1/drive` is accessible

Run the app and check the console logs to see exactly where the issue occurs!
