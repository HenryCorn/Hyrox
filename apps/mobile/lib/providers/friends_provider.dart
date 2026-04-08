import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class FriendUser {
  final String id;
  final String displayName;
  final String? avatarUrl;
  const FriendUser({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  factory FriendUser.fromJson(Map<String, dynamic> j) => FriendUser(
        id: j['id'] as String,
        displayName: j['displayName'] as String,
        avatarUrl: j['avatarUrl'] as String?,
      );
}

class Friend {
  final String friendshipId;
  final FriendUser user;
  final DateTime friendsSince;
  const Friend({
    required this.friendshipId,
    required this.user,
    required this.friendsSince,
  });

  factory Friend.fromJson(Map<String, dynamic> j) => Friend(
        friendshipId: j['friendshipId'] as String,
        user: FriendUser.fromJson(j['friend'] as Map<String, dynamic>),
        friendsSince: DateTime.parse(j['friendsSince'] as String),
      );
}

class FriendRequest {
  final String friendshipId;
  final FriendUser from;
  final DateTime sentAt;
  const FriendRequest({
    required this.friendshipId,
    required this.from,
    required this.sentAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> j) => FriendRequest(
        friendshipId: j['friendshipId'] as String,
        from: FriendUser.fromJson(j['from'] as Map<String, dynamic>),
        sentAt: DateTime.parse(j['sentAt'] as String),
      );
}

class UserSearchResult {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? friendshipStatus;
  const UserSearchResult({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.friendshipStatus,
  });

  UserSearchResult copyWith({String? friendshipStatus}) => UserSearchResult(
        id: id,
        displayName: displayName,
        avatarUrl: avatarUrl,
        friendshipStatus: friendshipStatus ?? this.friendshipStatus,
      );

  factory UserSearchResult.fromJson(Map<String, dynamic> j) => UserSearchResult(
        id: j['id'] as String,
        displayName: j['displayName'] as String,
        avatarUrl: j['avatarUrl'] as String?,
        friendshipStatus: j['friendshipStatus'] as String?,
      );
}

// ── Friends list ──────────────────────────────────────────────────────────────

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<Friend>>(FriendsNotifier.new);

class FriendsNotifier extends AsyncNotifier<List<Friend>> {
  @override
  Future<List<Friend>> build() => _fetchFriends();

  Future<List<Friend>> _fetchFriends() async {
    final api = ref.read(apiClientProvider);
    final response = await api.get<List<dynamic>>('/api/friends');
    return (response.data ?? [])
        .map((e) => Friend.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchFriends);
  }

  Future<void> removeFriend(String friendshipId) async {
    final api = ref.read(apiClientProvider);
    await api.delete('/api/friends/$friendshipId');
    final current = state.value ?? [];
    state = AsyncData(
      current.where((f) => f.friendshipId != friendshipId).toList(),
    );
  }
}

// ── Friend requests ───────────────────────────────────────────────────────────

final friendRequestsProvider =
    AsyncNotifierProvider<FriendRequestsNotifier, List<FriendRequest>>(
        FriendRequestsNotifier.new);

class FriendRequestsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  Future<List<FriendRequest>> build() => _fetchRequests();

  Future<List<FriendRequest>> _fetchRequests() async {
    final api = ref.read(apiClientProvider);
    final response = await api.get<List<dynamic>>('/api/friends/requests');
    return (response.data ?? [])
        .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> accept(String friendshipId) async {
    final api = ref.read(apiClientProvider);
    await api.put('/api/friends/requests/$friendshipId/accept');
    _removeRequest(friendshipId);
    ref.invalidate(friendsProvider);
  }

  Future<void> decline(String friendshipId) async {
    final api = ref.read(apiClientProvider);
    await api.put('/api/friends/requests/$friendshipId/decline');
    _removeRequest(friendshipId);
  }

  void _removeRequest(String id) {
    final current = state.value ?? [];
    state = AsyncData(current.where((r) => r.friendshipId != id).toList());
  }
}

// ── User search ───────────────────────────────────────────────────────────────

/// Search results keyed by query string. Invalidate to re-fetch.
final userSearchProvider =
    FutureProvider.family<List<UserSearchResult>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final api = ref.read(apiClientProvider);
  final response = await api.get<List<dynamic>>(
    '/api/users/search',
    query: {'q': query.trim()},
  );
  return (response.data ?? [])
      .map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Sends a friend request. Call directly from the widget; invalidates search.
Future<void> sendFriendRequest(WidgetRef ref, String addresseeId) async {
  final api = ref.read(apiClientProvider);
  await api.post('/api/friends/requests', data: {'addresseeId': addresseeId});
}
