import 'package:flutter/material.dart';
import 'campus_shared.dart';

/* =====================================================================
   DATA: Report model + in-memory store (no backend needed for the demo)
   ===================================================================== */

class Report {
  final String ref, title, category, organization, priority, description;
  final DateTime date, createdAt;
  const Report({
    required this.ref,
    required this.title,
    required this.category,
    required this.organization,
    required this.priority,
    required this.description,
    required this.date,
    required this.createdAt,
  });
}

class ReportStore extends ChangeNotifier {
  ReportStore._();
  static final ReportStore instance = ReportStore._();

  final List<Report> _items = [];
  int _seq = 0;

  /// Newest first.
  List<Report> get items => List.unmodifiable(_items.reversed);
  int get count => _items.length;

  Report add({
    required String title,
    required String category,
    required String organization,
    required String priority,
    required String description,
    required DateTime date,
  }) {
    _seq++;
    final now = DateTime.now();
    final r = Report(
      ref: 'RPT-${now.year}-${_seq.toString().padLeft(4, '0')}',
      title: title,
      category: category,
      organization: organization,
      priority: priority,
      description: description,
      date: date,
      createdAt: now,
    );
    _items.add(r);
    notifyListeners();
    return r;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

String formatDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

Color priorityColor(String p) {
  switch (p) {
    case 'High':
      return const Color(0xFFFF8A65);
    case 'Medium':
      return C.gold;
    default:
      return C.lime;
  }
}

/* =====================================================================
   SCREEN
   ===================================================================== */

enum SubmitStatus { idle, loading, success, error }

class ReportFormPage extends StatefulWidget {
  /// 0 = New report, 1 = My reports
  final int initialTab;
  const ReportFormPage({super.key, this.initialTab = 0});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage>
    with SingleTickerProviderStateMixin {
  static const _categories = [
    'Event',
    'Membership',
    'Finance',
    'Facilities',
    'Safety',
    'Other'
  ];
  static const _priorities = ['Low', 'Medium', 'High'];

  final _store = ReportStore.instance;
  late final TabController _tabs;

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _org = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _desc = TextEditingController();
  final _search = TextEditingController();

  String? _category;
  String _priority = 'Medium';
  DateTime? _date;
  bool _confirm = false;
  bool _categoryError = false;
  bool _confirmError = false;

  SubmitStatus _status = SubmitStatus.idle;
  bool _simulateFailure = false; // demo switch -> triggers ERROR state
  Report? _lastReport;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab.clamp(0, 1));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _title.dispose();
    _org.dispose();
    _dateCtrl.dispose();
    _desc.dispose();
    _search.dispose();
    super.dispose();
  }

  bool get _busy => _status == SubmitStatus.loading;

  /* ------------------------------ actions ------------------------------ */

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = formatDate(picked);
      });
    }
  }

  void _fillSample() {
    setState(() {
      _title.text = 'Broken projector in Hall B';
      _org.text = 'Computer Science Society';
      _category = 'Facilities';
      _priority = 'High';
      _date = DateTime.now();
      _dateCtrl.text = formatDate(_date!);
      _desc.text =
          'The projector in Hall B stopped working during our weekly meeting. '
          'We need a replacement before the upcoming hackathon.';
      _confirm = true;
      _categoryError = false;
      _confirmError = false;
      if (_status == SubmitStatus.error) _status = SubmitStatus.idle;
    });
  }

  void _resetForm() {
    _title.clear();
    _org.clear();
    _dateCtrl.clear();
    _desc.clear();
    setState(() {
      _category = null;
      _priority = 'Medium';
      _date = null;
      _confirm = false;
      _categoryError = false;
      _confirmError = false;
      _status = SubmitStatus.idle;
      _lastReport = null;
    });
  }

  Future<void> _submit() async {
    if (_busy) return; // duplicate-submission guard

    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _categoryError = _category == null;
      _confirmError = !_confirm;
    });
    if (!formOk || _category == null || !_confirm) return;

    setState(() => _status = SubmitStatus.loading);

    try {
      // Simulated network request (3 s so the LOADING state is easy to capture)
      await Future.delayed(const Duration(seconds: 3));
      if (_simulateFailure) {
        throw Exception('Simulated server failure (503)');
      }
      final report = _store.add(
        title: _title.text.trim(),
        category: _category!,
        organization: _org.text.trim(),
        priority: _priority,
        description: _desc.text.trim(),
        date: _date!,
      );
      if (!mounted) return;
      setState(() {
        _lastReport = report;
        _status = SubmitStatus.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = SubmitStatus.error);
    }
  }

  /* ------------------------------ build ------------------------------ */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.ink900,
      appBar: AppBar(
        backgroundColor: C.ink800,
        elevation: 0,
        iconTheme: const IconThemeData(color: C.lime),
        title: Row(children: const [
          CampusMark(size: 28),
          SizedBox(width: 10),
          Text('Reports',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFF3FAF3))),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(73), // icon + text tabs
          child: Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: C.line))),
            child: ListenableBuilder(
              listenable: _store,
              builder: (_, __) => TabBar(
                controller: _tabs,
                indicatorColor: C.lime,
                labelColor: C.lime,
                unselectedLabelColor: C.muted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  const Tab(
                      icon: Icon(Icons.edit_note, size: 20),
                      text: 'New report'),
                  Tab(
                      icon: const Icon(Icons.list_alt, size: 20),
                      text: 'My reports (${_store.count})'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _store,
        builder: (_, __) => TabBarView(
          controller: _tabs,
          children: [_newReportTab(), _reportsTab()],
        ),
      ),
    );
  }

  /* ------------------------------ TAB 1 ------------------------------ */

  Widget _newReportTab() {
    return _Page(
      child: _status == SubmitStatus.success
          ? _successView()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Submit a report',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF3FAF3))),
                const SizedBox(height: 6),
                const Text(
                    'Tell the campus team about an issue, incident or request.',
                    style: TextStyle(fontSize: 13, color: C.muted)),
                const SizedBox(height: 20),
                if (_status == SubmitStatus.loading) _loadingView(),
                if (_status == SubmitStatus.error) _errorView(),
                _formBody(),
                const SizedBox(height: 22),
                _demoControls(),
              ],
            ),
    );
  }

  /// LOADING — message + progress bar; fields and button are disabled.
  Widget _loadingView() {
    return Notice(
      kind: NoticeKind.info,
      title: 'Submitting your report…',
      message:
          'Please wait. The form is locked so the report can’t be sent twice.',
      extra: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const LinearProgressIndicator(
          minHeight: 5,
          color: C.lime,
          backgroundColor: C.ink800,
        ),
      ),
    );
  }

  /// ERROR — clear explanation + Retry and correction actions.
  Widget _errorView() {
    return Notice(
      kind: NoticeKind.error,
      title: 'Submission failed',
      message:
          'We couldn’t reach the server, so your report was NOT saved. '
          'Your details are still in the form. Check your connection and retry, '
          'or edit your details first.',
      actions: [
        GradientButton(
          label: 'Retry',
          icon: Icons.refresh,
          expand: false,
          onPressed: _submit,
        ),
        OutlineAction(
          label: 'Edit details',
          icon: Icons.edit_outlined,
          onPressed: () => setState(() => _status = SubmitStatus.idle),
        ),
      ],
    );
  }

  /// SUCCESS — confirmation + meaningful next actions.
  Widget _successView() {
    final r = _lastReport!;
    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 110,
                child: Text(k,
                    style: const TextStyle(
                        color: C.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
            Expanded(
                child: Text(v,
                    style: const TextStyle(color: C.text, fontSize: 13))),
          ]),
        );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: C.ink700,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.lineHi),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fade(C.leaf, 0.18),
                border: Border.all(color: C.lime, width: 2),
              ),
              child: const Icon(Icons.check, size: 40, color: C.lime),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Report submitted!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF3FAF3))),
          const SizedBox(height: 6),
          const Text('Your report was saved and sent to the campus team.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: C.muted)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.ink800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.line),
            ),
            child: Column(children: [
              row('Reference', r.ref),
              row('Title', r.title),
              row('Category', r.category),
              row('Organization', r.organization),
              row('Priority', r.priority),
              row('Incident date', formatDate(r.date)),
            ]),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              GradientButton(
                label: 'View my reports',
                icon: Icons.list_alt,
                expand: false,
                onPressed: () {
                  _tabs.animateTo(1);
                },
              ),
              OutlineAction(
                label: 'Submit another report',
                icon: Icons.add,
                onPressed: _resetForm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formBody() {
    final enabled = !_busy;
    Widget sectionLabel(String t) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: C.label,
                  letterSpacing: 0.4)),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CampusField(
            label: 'Report title',
            controller: _title,
            hint: 'e.g. Broken projector in Hall B',
            enabled: enabled,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Please enter a title.';
              if (s.length < 5) return 'Title must be at least 5 characters.';
              return null;
            },
          ),

          // category chips
          sectionLabel('Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _categories)
                ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  showCheckmark: false,
                  selectedColor: fade(C.lime, 0.9),
                  backgroundColor: C.ink700,
                  side: BorderSide(
                      color: _categoryError ? C.gold : C.line),
                  labelStyle: TextStyle(
                      color: _category == c ? C.onGradient : C.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  onSelected: enabled
                      ? (_) => setState(() {
                            _category = c;
                            _categoryError = false;
                          })
                      : null,
                ),
            ],
          ),
          if (_categoryError)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text('Please choose a category.',
                  style: TextStyle(color: Color(0xFFFFC86B), fontSize: 12)),
            ),

          CampusField(
            label: 'Organization / club',
            controller: _org,
            hint: 'e.g. Computer Science Society',
            enabled: enabled,
            textInputAction: TextInputAction.next,
            validator: (v) => (v ?? '').trim().isEmpty
                ? 'Please enter the organization.'
                : null,
          ),
          CampusField(
            label: 'Date of incident / activity',
            controller: _dateCtrl,
            hint: 'Tap to pick a date',
            enabled: enabled,
            readOnly: true,
            onTap: enabled ? _pickDate : null,
            suffix: const Icon(Icons.calendar_month_outlined,
                size: 18, color: C.muted),
            validator: (v) =>
                (v ?? '').isEmpty ? 'Please pick a date.' : null,
          ),

          // priority
          sectionLabel('Priority'),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _priorities)
                ChoiceChip(
                  label: Text(p),
                  selected: _priority == p,
                  showCheckmark: false,
                  selectedColor: fade(priorityColor(p), 0.9),
                  backgroundColor: C.ink700,
                  side: const BorderSide(color: C.line),
                  labelStyle: TextStyle(
                      color: _priority == p ? C.onGradient : C.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  onSelected: enabled
                      ? (_) => setState(() => _priority = p)
                      : null,
                ),
            ],
          ),

          CampusField(
            label: 'Description',
            controller: _desc,
            hint: 'Describe what happened (at least 20 characters)',
            enabled: enabled,
            maxLines: 5,
            maxLength: 500,
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Please describe the issue.';
              if (s.length < 20) {
                return 'Add a little more detail (20+ characters).';
              }
              return null;
            },
          ),

          // confirmation checkbox
          Row(children: [
            Checkbox(
              value: _confirm,
              activeColor: C.lime,
              checkColor: C.onGradient,
              side: BorderSide(color: _confirmError ? C.gold : C.lineHi),
              onChanged: enabled
                  ? (v) => setState(() {
                        _confirm = v ?? false;
                        _confirmError = false;
                      })
                  : null,
            ),
            const Expanded(
              child: Text('I confirm the information above is accurate.',
                  style: TextStyle(color: C.text, fontSize: 13)),
            ),
          ]),
          if (_confirmError)
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 4),
              child: Text('Please confirm before submitting.',
                  style: TextStyle(color: Color(0xFFFFC86B), fontSize: 12)),
            ),

          const SizedBox(height: 18),
          GradientButton(
            label: _busy ? 'Submitting…' : 'Submit report',
            loading: _busy,
            onPressed: _busy ? null : _submit, // disabled while pending
          ),
        ],
      ),
    );
  }

  /// Presenter helpers so every state can be reproduced live.
  Widget _demoControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.ink800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.science_outlined, size: 16, color: C.gold),
          SizedBox(width: 8),
          Text('DEMO CONTROLS',
              style: TextStyle(
                  fontSize: 11,
                  color: C.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 6),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: C.gold,
          value: _simulateFailure,
          onChanged: (v) => setState(() => _simulateFailure = v),
          title: const Text('Simulate server failure',
              style: TextStyle(color: C.text, fontSize: 14)),
          subtitle: const Text(
              'ON → next submit fails (ERROR state). Turn OFF, then press Retry to recover.',
              style: TextStyle(color: C.muted, fontSize: 12)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _busy ? null : _fillSample,
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text('Fill sample data'),
            style: TextButton.styleFrom(foregroundColor: C.lime),
          ),
        ),
      ]),
    );
  }

  /* ------------------------------ TAB 2 ------------------------------ */

  Widget _reportsTab() {
    final all = _store.items;
    final q = _search.text.trim().toLowerCase();
    final shown = q.isEmpty
        ? all
        : all
            .where((r) =>
                r.title.toLowerCase().contains(q) ||
                r.category.toLowerCase().contains(q) ||
                r.organization.toLowerCase().contains(q) ||
                r.ref.toLowerCase().contains(q))
            .toList();

    // EMPTY (a): no reports have been created yet
    if (all.isEmpty) {
      return _Page(
        child: _EmptyState(
          icon: Icons.inbox_outlined,
          title: 'No reports yet',
          message:
              'You haven’t created any reports. Submit your first one and it will show up here.',
          actionLabel: 'Create a report',
          actionIcon: Icons.add,
          onAction: () {
            if (_status == SubmitStatus.success) _resetForm();
            _tabs.animateTo(0);
          },
        ),
      );
    }

    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Expanded(
              child: Text('My reports',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF3FAF3))),
            ),
            TextButton.icon(
              onPressed: () {
                _search.clear();
                _store.clear();
              },
              icon: const Icon(Icons.delete_sweep_outlined, size: 16),
              label: const Text('Clear all (demo)'),
              style: TextButton.styleFrom(foregroundColor: C.muted),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            cursorColor: C.lime,
            style: const TextStyle(color: C.text, fontSize: 14),
            decoration: campusDecoration(
              hint: 'Search by title, category, organization or reference',
              prefix: const Icon(Icons.search, size: 18, color: C.muted),
            ),
          ),
          const SizedBox(height: 16),

          // EMPTY (b): search has no matches
          if (shown.isEmpty)
            _EmptyState(
              icon: Icons.search_off,
              title: 'No matching reports',
              message: 'Nothing matches “${_search.text.trim()}”. '
                  'Try a different keyword or clear the search.',
              actionLabel: 'Clear search',
              actionIcon: Icons.close,
              onAction: () => setState(() => _search.clear()),
            )
          else
            for (final r in shown) _ReportCard(report: r),
        ],
      ),
    );
  }
}

/* =====================================================================
   SMALL WIDGETS
   ===================================================================== */

class _Page extends StatelessWidget {
  final Widget child;
  const _Page({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.ink900, C.ink800],
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon, actionIcon;
  final String title, message, actionLabel;
  final VoidCallback onAction;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: C.ink700,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
      ),
      child: Column(children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fade(C.leaf, 0.12),
            border: Border.all(color: fade(C.lime, 0.3)),
          ),
          child: Icon(icon, size: 36, color: C.lime),
        ),
        const SizedBox(height: 18),
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF3FAF3))),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: C.muted, height: 1.4)),
        ),
        const SizedBox(height: 22),
        GradientButton(
            label: actionLabel,
            icon: actionIcon,
            expand: false,
            onPressed: onAction),
      ]),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final pc = priorityColor(report.priority);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: C.ink700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 4, color: pc),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(report.title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: C.text)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: fade(pc, 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: fade(pc, 0.5)),
                        ),
                        child: Text(report.priority,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: pc)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text('${report.organization} · ${report.category}',
                        style: const TextStyle(fontSize: 12, color: C.label)),
                    const SizedBox(height: 8),
                    Text(report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: C.muted, height: 1.35)),
                    const SizedBox(height: 10),
                    Text('${report.ref}  ·  ${formatDate(report.date)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: C.gold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}