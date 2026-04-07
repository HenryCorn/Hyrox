import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/friends_provider.dart';
import '../../services/ad_service.dart';
import '../theme/nothing_theme.dart';
import '../widgets/banner_ad_widget.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(onBack: () => Navigator.of(context).pop()),
            TabBar(
              controller: _tabs,
              labelStyle: GoogleFonts.spaceMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              unselectedLabelColor: NothingTheme.textDisabled,
              labelColor: NothingTheme.textDisplay,
              indicatorColor: NothingTheme.accent,
              indicatorWeight: 1,
              dividerColor: NothingTheme.borderSubtle,
              tabs: const [
                Tab(text: 'FRIENDS'),
                Tab(text: 'REQUESTS'),
                Tab(text: 'FIND'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _FriendsTab(),
                  _RequestsTab(),
                  _SearchTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 18, color: NothingTheme.textSecondary),
            onPressed: onBack,
            padding: const EdgeInsets.all(8),
          ),
          const Spacer(),
          Text(
            'FRIENDS',
            style: NothingTheme.label(
                fontSize: 11, color: NothingTheme.textSecondary),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ── Friends tab ───────────────────────────────────────────────────────────────

class _FriendsTab extends ConsumerWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);

    return Column(
      children: [
        Expanded(
          child: friends.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: NothingTheme.accent)),
            error: (e, _) => _ErrorView(
                message: e.toString(),
                onRetry: () => ref.read(friendsProvider.notifier).refresh()),
            data: (list) {
              if (list.isEmpty) {
                return const _EmptyView(
                  label: 'No friends yet.',
                  hint: 'Find athletes on the FIND tab.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    Divider(color: NothingTheme.borderSubtle, height: 1),
                itemBuilder: (context, i) => _FriendTile(friend: list[i]),
              );
            },
          ),
        ),
        // Banner — shown while user browses their friends list
        Center(child: BannerAdWidget(adUnitId: AdIds.bannerFriends)),
      ],
    );
  }
}

class _FriendTile extends ConsumerWidget {
  const _FriendTile({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: _Avatar(name: friend.user.displayName),
      title: Text(
        friend.user.displayName.toUpperCase(),
        style: NothingTheme.label(fontSize: 12, color: NothingTheme.textDisplay),
      ),
      subtitle: Text(
        'FRIENDS SINCE ${_fmt(friend.friendsSince)}',
        style: NothingTheme.label(fontSize: 9, color: NothingTheme.textDisabled),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.person_remove_outlined,
            size: 18, color: NothingTheme.textDisabled),
        onPressed: () async {
          final confirmed = await _confirmRemove(context, friend.user.displayName);
          if (confirmed && context.mounted) {
            await ref
                .read(friendsProvider.notifier)
                .removeFriend(friend.friendshipId);
          }
        },
      ),
    );
  }

  Future<bool> _confirmRemove(BuildContext context, String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NothingTheme.surface,
        title: Text('Remove $name?',
            style: NothingTheme.label(
                fontSize: 14, color: NothingTheme.textDisplay)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL',
                style:
                    NothingTheme.label(fontSize: 11, color: NothingTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('REMOVE',
                style: NothingTheme.label(
                    fontSize: 11, color: NothingTheme.danger)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Requests tab ──────────────────────────────────────────────────────────────

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(friendRequestsProvider);

    return Column(
      children: [
        Expanded(
          child: requests.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: NothingTheme.accent)),
            error: (e, _) => _ErrorView(message: e.toString(), onRetry: null),
            data: (list) {
              if (list.isEmpty) {
                return const _EmptyView(
                  label: 'No pending requests.',
                  hint: 'When someone adds you, you\'ll see it here.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    Divider(color: NothingTheme.borderSubtle, height: 1),
                itemBuilder: (context, i) => _RequestTile(request: list[i]),
              );
            },
          ),
        ),
        Center(child: BannerAdWidget(adUnitId: AdIds.bannerFriends)),
      ],
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.request});
  final FriendRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(friendRequestsProvider.notifier);
    return ListTile(
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: _Avatar(name: request.from.displayName),
      title: Text(
        request.from.displayName.toUpperCase(),
        style: NothingTheme.label(fontSize: 12, color: NothingTheme.textDisplay),
      ),
      subtitle: Text(
        'SENT ${_fmtRelative(request.sentAt)}',
        style: NothingTheme.label(fontSize: 9, color: NothingTheme.textDisabled),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, size: 20, color: NothingTheme.accent),
            onPressed: () => notifier.accept(request.friendshipId),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: NothingTheme.textDisabled),
            onPressed: () => notifier.decline(request.friendshipId),
          ),
        ],
      ),
    );
  }

  static String _fmtRelative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays}D AGO';
    if (diff.inHours > 0) return '${diff.inHours}H AGO';
    return '${diff.inMinutes}M AGO';
  }
}

// ── Search tab ────────────────────────────────────────────────────────────────

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: TextField(
            autofocus: false,
            style: NothingTheme.label(fontSize: 13, color: NothingTheme.textDisplay),
            decoration: InputDecoration(
              hintText: 'Search athletes...',
              hintStyle: NothingTheme.label(
                  fontSize: 13, color: NothingTheme.textDisabled),
              filled: true,
              fillColor: NothingTheme.surface,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: NothingTheme.borderSubtle),
                borderRadius: BorderRadius.zero,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: NothingTheme.borderSubtle),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: NothingTheme.accent),
                borderRadius: BorderRadius.zero,
              ),
              prefixIcon:
                  const Icon(Icons.search, color: NothingTheme.textDisabled, size: 18),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        // Mid-page banner above results
        Center(child: BannerAdWidget(adUnitId: AdIds.bannerFriends)),
        const SizedBox(height: 4),
        Expanded(child: _SearchResults(query: _query)),
        // Bottom banner pinned below results
        Center(child: BannerAdWidget(adUnitId: AdIds.bannerFriends)),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().length < 2) {
      return const _EmptyView(
        label: 'Search for athletes.',
        hint: 'Enter at least 2 characters.',
      );
    }

    final results = ref.watch(userSearchProvider(query));

    return results.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: NothingTheme.accent)),
      error: (e, _) => _ErrorView(message: e.toString(), onRetry: null),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyView(label: 'No results for "$query".');
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) =>
              Divider(color: NothingTheme.borderSubtle, height: 1),
          itemBuilder: (context, i) => _SearchResultTile(
            result: list[i],
            onAdd: () async {
              await sendFriendRequest(ref, list[i].id);
              ref.invalidate(userSearchProvider(query));
            },
          ),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result, required this.onAdd});
  final UserSearchResult result;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final status = result.friendshipStatus;
    final isAlreadyFriend = status == 'Accepted';
    final isPending = status == 'Pending';

    return ListTile(
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: _Avatar(name: result.displayName),
      title: Text(
        result.displayName.toUpperCase(),
        style: NothingTheme.label(fontSize: 12, color: NothingTheme.textDisplay),
      ),
      subtitle: status != null
          ? Text(
              status.toUpperCase(),
              style: NothingTheme.label(
                  fontSize: 9,
                  color: isAlreadyFriend
                      ? NothingTheme.accent
                      : NothingTheme.textDisabled),
            )
          : null,
      trailing: isAlreadyFriend || isPending
          ? null
          : IconButton(
              icon: const Icon(Icons.person_add_outlined,
                  size: 18, color: NothingTheme.textPrimary),
              onPressed: onAdd,
            ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
      color: NothingTheme.surface,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: NothingTheme.accent,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.label, this.hint});
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  NothingTheme.label(fontSize: 13, color: NothingTheme.textSecondary)),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(hint!,
                style: NothingTheme.label(
                    fontSize: 11, color: NothingTheme.textDisabled)),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Error loading data',
              style: NothingTheme.label(fontSize: 13, color: NothingTheme.danger)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetry,
              child: Text('RETRY',
                  style: NothingTheme.label(
                      fontSize: 11, color: NothingTheme.textSecondary)),
            ),
          ],
        ],
      ),
    );
  }
}
