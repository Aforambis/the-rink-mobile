# TODO: Fix Login Persistence Issue & Update Profile Screen

## Completed Tasks
- [x] Analyze the login persistence issue in Flutter app
- [x] Identify that MainNavigationScreen's _isLoggedIn state wasn't synced with CookieRequest.loggedIn
- [x] Update MainNavigationScreen to use CookieRequest.loggedIn via context.read in event handlers
- [x] Fix sign out functionality to call CookieRequest.logout()
- [x] Remove manual _isLoggedIn state management
- [x] Fix Provider assertion error by using context.read instead of context.watch in event handlers
- [x] Update ProfileScreen to fetch real user data (username, email) from Django backend
- [x] Add loading state and error handling for user data fetching
- [x] Convert ProfileScreen from StatelessWidget to StatefulWidget for data fetching
- [x] Fix Profile navigation button to show ProfileScreen instead of HomeEventsScreen
- [x] Add get_user_data endpoint to Django backend (auth_mob/views.py)
- [x] Add user data URL pattern to Django URLs (auth_mob/urls.py)

## Summary
The issue was that the MainNavigationScreen had its own local _isLoggedIn boolean that started as false and wasn't updated when the user logged in via the LoginPage. The CookieRequest from pbp_django_auth handles session persistence with cookies, but the UI wasn't checking this status.

The Provider assertion error occurred because context.watch was called from event handlers (like onTap), which are executed outside the widget tree. The fix was to use context.read instead of context.watch for reading values in event handlers, since we don't need to listen for changes in those contexts.

The ProfileScreen was updated to display real user data from the Django backend instead of hardcoded values, with proper loading states and error handling.

The Profile navigation button was incorrectly showing the HomeEventsScreen (packages) instead of the ProfileScreen due to missing case 4 in the _getSelectedScreen() switch statement.

The Flutter app was trying to fetch user data from '/auth_mob/user/' but this endpoint didn't exist in Django, so we added the get_user_data view function and URL pattern.

Changes made:
- Removed local _isLoggedIn variable and getter
- Used context.read<CookieRequest>().loggedIn in event handlers (_onNavTap, _handleActionButton, _getSelectedScreen)
- Updated onSignOut callback to call request.logout() instead of manually setting _isLoggedIn = false
- Added necessary imports for CookieRequest and Provider
- Modified ProfileScreen to fetch user data from '/auth_mob/user/' endpoint
- Added loading indicator and error handling for user data fetching
- Display actual username and email from backend response
- Added case 4 in _getSelectedScreen() to return ProfileScreen with proper callbacks
- Added get_user_data function to Django views.py that returns username and email for authenticated users
- Added 'user/' URL pattern to Django urls.py

The login state should now persist across app sessions and navigation, the Provider assertion error is resolved, the profile screen shows real user data from the Django backend, the Profile navigation button correctly shows the ProfileScreen, and the Django backend now provides the user data endpoint.
