import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'
    hide ImageSource;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/notice_provider.dart';

class AdminNoticeFormScreen extends ConsumerStatefulWidget {
  const AdminNoticeFormScreen({super.key, this.noticeId});

  final String? noticeId;

  @override
  ConsumerState<AdminNoticeFormScreen> createState() =>
      _AdminNoticeFormScreenState();
}

class _AdminNoticeFormScreenState extends ConsumerState<AdminNoticeFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _htmlCtrl = TextEditingController();

  late TabController _tabController;

  bool _isPublished = true;
  DateTime _publishedAt = DateTime.now();
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _htmlCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotice() async {
    if (_initialized || widget.noticeId == null) {
      _initialized = true;
      return;
    }
    _initialized = true;
    final notice = await ref
        .read(noticeRepositoryProvider)
        .fetchNoticeByIdForAdmin(widget.noticeId!);
    if (notice == null || !mounted) return;
    setState(() {
      _titleCtrl.text = notice.title;
      _bodyCtrl.text = notice.body;
      _htmlCtrl.text = _initialHtmlFromNotice(
        contentHtml: notice.contentHtml,
        body: notice.body,
      );
      _isPublished = notice.isPublished;
      _publishedAt = notice.publishedAt;
    });
  }

  Future<void> _pickAndInsertImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _loading = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last;
      final fileName = '${const Uuid().v4()}.$ext';
      final url = await ref
          .read(noticeRepositoryProvider)
          .uploadNoticeImage(fileName, bytes);

      final tag = '\n<img src="$url" style="max-width:100%;" />\n';
      final text = _htmlCtrl.text.trim().isEmpty
          ? _plainTextToHtml(_bodyCtrl.text)
          : _htmlCtrl.text;
      final rawOffset = _htmlCtrl.selection.baseOffset;
      final insertOffset =
          rawOffset < 0 ? text.length : rawOffset.clamp(0, text.length);
      final nextText =
          text.substring(0, insertOffset) + tag + text.substring(insertOffset);

      _htmlCtrl.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: insertOffset + tag.length),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _publishedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _publishedAt.hour,
          _publishedAt.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(noticeRepositoryProvider);
      final htmlContent = _htmlCtrl.text.trim().isEmpty ? null : _htmlCtrl.text;

      if (widget.noticeId == null) {
        await repo.createNotice(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          contentHtml: htmlContent,
          publishedAt: _publishedAt,
          isPublished: _isPublished,
        );
      } else {
        await repo.updateNotice(
          id: widget.noticeId!,
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          contentHtml: htmlContent,
          publishedAt: _publishedAt,
          isPublished: _isPublished,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadNotice(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(widget.noticeId == null ? '공지 작성' : '공지 수정'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '편집'),
                Tab(text: '미리보기'),
              ],
            ),
            actions: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: _save,
                  child: const Text('저장'),
                ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildEditor(),
              _buildPreview(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditor() {
    final dateFmt = DateFormat('yyyy.MM.dd').format(_publishedAt);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('제목'),
          TextFormField(
            controller: _titleCtrl,
            decoration: _inputDecoration('공지 제목'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
          ),
          const SizedBox(height: 16),
          _sectionLabel('요약 (앱 목록에 표시)'),
          TextFormField(
            controller: _bodyCtrl,
            decoration: _inputDecoration('한 줄 요약'),
            maxLines: 2,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '요약을 입력하세요' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _sectionLabel('HTML 본문'),
              const Spacer(),
              TextButton.icon(
                onPressed: _loading ? null : _pickAndInsertImage,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: const Text('이미지 삽입'),
              ),
            ],
          ),
          TextFormField(
            controller: _htmlCtrl,
            decoration: _inputDecoration('<p>내용을 입력하세요...</p>'),
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(dateFmt, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Text('공개', style: AppTextStyles.body),
                  Switch(
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final html = _htmlCtrl.text.trim();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _titleCtrl.text.isEmpty ? '(제목 없음)' : _titleCtrl.text,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('yyyy.MM.dd HH:mm').format(_publishedAt),
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: html.isEmpty
              ? const Text('(HTML 내용 없음)', style: AppTextStyles.bodySecondary)
              : HtmlWidget(
                  html,
                  textStyle: AppTextStyles.body.copyWith(height: 1.6),
                ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.label),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _initialHtmlFromNotice({
    required String? contentHtml,
    required String body,
  }) {
    final html = contentHtml?.trim();
    if (html != null && html.isNotEmpty) return contentHtml!;
    return _plainTextToHtml(body);
  }

  String _plainTextToHtml(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    const escape = HtmlEscape();
    return trimmed.split(RegExp(r'\n\s*\n')).map((paragraph) {
      final escaped = escape.convert(paragraph.trim());
      return '<p>${escaped.replaceAll('\n', '<br />')}</p>';
    }).join('\n');
  }
}
