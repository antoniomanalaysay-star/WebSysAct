import 'package:flutter/material.dart';
import 'campus_shared.dart';
import 'report_form_screen.dart';
import 'login_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _soon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name is coming soon.')));
  }

  void _logout(BuildContext context) {
    AuthService.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  void _open(BuildContext context, int tab) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReportFormPage(initialTab: tab)));
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.currentUsername ?? 'Student';
    final store = ReportStore.instance;

    return Scaffold(
      backgroundColor: C.ink900,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [C.ink900, Color(0xFF07200F), Color(0xFF0E3A1F)],
            stops: [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _TopBar(name: name, onLogout: () => _logout(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: ListenableBuilder(
                      listenable: store,
                      builder: (context, _) => LayoutBuilder(
                        builder: (context, c) {
                          final w = c.maxWidth;
                          final cols = w > 800 ? 3 : (w > 520 ? 2 : 1);
                          const gap = 16.0;
                          final tileW = (w - gap * (cols - 1)) / cols;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _hero(context, name),
                              const SizedBox(height: 20),
                              _stats(store, tileW, gap),
                              const SizedBox(height: 28),
                              const Text('QUICK ACTIONS',
                                  style: TextStyle(
                                      color: C.lime,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 12),
                              Wrap(spacing: gap, runSpacing: gap, children: [
                                _ActionTile(
                                    width: tileW,
                                    icon: Icons.edit_note,
                                    title: 'Submit a report',
                                    subtitle: 'Report an issue or incident',
                                    highlight: true,
                                    onTap: () => _open(context, 0)),
                                _ActionTile(
                                    width: tileW,
                                    icon: Icons.list_alt,
                                    title: 'My reports',
                                    subtitle: '${store.count} submitted',
                                    onTap: () => _open(context, 1)),
                                _ActionTile(
                                    width: tileW,
                                    icon: Icons.calendar_month_outlined,
                                    title: 'Events',
                                    subtitle: 'Campus calendar',
                                    gold: true,
                                    onTap: () => _soon(context, 'Events')),
                                _ActionTile(
                                    width: tileW,
                                    icon: Icons.groups_outlined,
                                    title: 'Members',
                                    subtitle: 'Manage your people',
                                    onTap: () => _soon(context, 'Members')),
                                _ActionTile(
                                    width: tileW,
                                    icon: Icons.hub_outlined,
                                    title: 'Organizations',
                                    subtitle: 'Clubs & societies',
                                    gold: true,
                                    onTap: () =>
                                        _soon(context, 'Organizations')),
                                _ActionTile(
                                    width: tileW,
                                    icon: Icons.chat_bubble_outline,
                                    title: 'Messages',
                                    subtitle: 'Stay in touch',
                                    onTap: () => _soon(context, 'Messages')),
                              ]),
                              const SizedBox(height: 28),
                              _recent(context, store),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.lineHi),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [C.ink600, C.ink700],
        ),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Welcome back, '),
                TextSpan(text: name, style: const TextStyle(color: C.gold)),
                const TextSpan(text: '!'),
              ]),
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF3FAF3)),
            ),
            const SizedBox(height: 8),
            const Text(
                'Manage your organizations, events, and members — and keep the campus team in the loop with reports.',
                style: TextStyle(fontSize: 14, color: C.muted, height: 1.4)),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Submit a report',
              icon: Icons.edit_note,
              expand: false,
              onPressed: () => _open(context, 0),
            ),
          ]),
        ),
        if (MediaQuery.of(context).size.width > 640) ...[
          const SizedBox(width: 20),
          const GlowLogo(size: 96),
        ],
      ]),
    );
  }

  Widget _stats(ReportStore store, double tileW, double gap) {
    final items = store.items;
    final high = items.where((r) => r.priority == 'High').length;
    return Wrap(spacing: gap, runSpacing: gap, children: [
      _Stat(width: tileW, label: 'REPORTS SUBMITTED', value: '${store.count}'),
      _Stat(
          width: tileW,
          label: 'HIGH PRIORITY',
          value: '$high',
          valueColor: const Color(0xFFFF8A65)),
      _Stat(
          width: tileW,
          label: 'LATEST REFERENCE',
          value: items.isEmpty ? '—' : items.first.ref,
          valueColor: C.gold,
          small: true),
    ]);
  }

  Widget _recent(BuildContext context, ReportStore store) {
    final items = store.items.take(3).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(
          child: Text('RECENT REPORTS',
              style: TextStyle(
                  color: C.lime,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
        ),
        if (items.isNotEmpty)
          TextButton(
              onPressed: () => _open(context, 1),
              style: TextButton.styleFrom(foregroundColor: C.gold),
              child: const Text('View all')),
      ]),
      const SizedBox(height: 8),
      if (items.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.ink700,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: C.line),
          ),
          child: const Text('No reports yet. Your submissions will appear here.',
              style: TextStyle(color: C.muted, fontSize: 13)),
        )
      else
        for (final r in items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.ink700,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.line),
            ),
            child: Row(children: [
              Icon(Icons.description_outlined, color: priorityColor(r.priority)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                          style: const TextStyle(
                              color: C.text, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${r.organization} · ${r.category}',
                          style:
                              const TextStyle(color: C.muted, fontSize: 12)),
                    ]),
              ),
              Text(r.ref,
                  style: const TextStyle(
                      color: C.gold, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
    ]);
  }
}

class _TopBar extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  const _TopBar({required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 560;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: C.ink800,
        border: Border(bottom: BorderSide(color: C.line)),
      ),
      child: Row(children: [
        const CampusMark(size: 36, glow: true),
        const SizedBox(width: 12),
        const WordMark(),
        const Spacer(),
        CircleAvatar(
          radius: 16,
          backgroundColor: C.gold,
          child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(
                  color: C.onGradient, fontWeight: FontWeight.bold)),
        ),
        if (!narrow) ...[
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(color: C.text, fontSize: 13)),
        ],
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Log out',
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: C.lime, size: 20),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final double width;
  final String label, value;
  final Color valueColor;
  final bool small;
  const _Stat({
    required this.width,
    required this.label,
    required this.value,
    this.valueColor = C.lime,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: C.ink700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: C.muted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: small ? 20 : 30,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title, subtitle;
  final bool gold, highlight;
  final VoidCallback onTap;
  const _ActionTile({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = gold ? C.gold : C.lime;
    return SizedBox(
      width: width,
      child: Material(
        color: highlight ? C.ink600 : C.ink700,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: highlight ? C.lime : C.line),
            ),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: fade(accent, 0.12),
                  border: Border.all(color: fade(accent, 0.3)),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: C.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style:
                              const TextStyle(color: C.muted, fontSize: 12)),
                    ]),
              ),
              const Icon(Icons.chevron_right, color: C.muted),
            ]),
          ),
        ),
      ),
    );
  }
}