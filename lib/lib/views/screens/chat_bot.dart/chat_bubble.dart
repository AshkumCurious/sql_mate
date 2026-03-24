import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';
import '../../../viewmodels/chat_viewmodel.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: _isUser
            ? _UserBubble(message: message)
            : _AssistantBubble(message: message),
      ),
    );
  }
}


class _UserBubble extends StatelessWidget {
  final ChatMessage message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Text(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}


class _AssistantBubble extends StatelessWidget {
  final ChatMessage message;

  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(color: AppTheme.border),
      ),
      child: _MarkdownContent(text: message.content),
    );
  }
}


enum _BlockType { paragraph, heading1, heading2, heading3, code, bullet }

class _Block {
  final _BlockType type;
  final String content;
  final String language;

  _Block({required this.type, required this.content, this.language = ''});
}


class _MarkdownContent extends StatelessWidget {
  final String text;

  const _MarkdownContent({required this.text});

  @override
  Widget build(BuildContext context) {
    final blocks = _parse(text);
    final widgets = <Widget>[];

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final isLast = i == blocks.length - 1;

      switch (block.type) {
        case _BlockType.heading1:
          widgets.add(_HeadingWidget(text: block.content, level: 1));
        case _BlockType.heading2:
          widgets.add(_HeadingWidget(text: block.content, level: 2));
        case _BlockType.heading3:
          widgets.add(_HeadingWidget(text: block.content, level: 3));
        case _BlockType.code:
          widgets.add(_CodeBlock(code: block.content, language: block.language));
        case _BlockType.bullet:
          widgets.add(_BulletItem(text: block.content));
        case _BlockType.paragraph:
          if (block.content.trim().isEmpty) break;
          widgets.add(_InlineText(text: block.content.trim()));
      }

      if (!isLast && block.type != _BlockType.bullet) {
        widgets.add(const Gap(8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<_Block> _parse(String input) {
    final blocks = <_Block>[];
    final codeRegex = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    int cursor = 0;

    for (final match in codeRegex.allMatches(input)) {
      if (match.start > cursor) {
        _parseTextBlocks(input.substring(cursor, match.start), blocks);
      }
      blocks.add(_Block(
        type: _BlockType.code,
        content: match.group(2) ?? '',
        language: match.group(1) ?? '',
      ));
      cursor = match.end;
    }

    if (cursor < input.length) {
      _parseTextBlocks(input.substring(cursor), blocks);
    }

    return blocks;
  }

  void _parseTextBlocks(String text, List<_Block> blocks) {
    for (final line in text.split('\n')) {
      if (line.startsWith('### ')) {
        blocks.add(_Block(type: _BlockType.heading3, content: line.substring(4)));
      } else if (line.startsWith('## ')) {
        blocks.add(_Block(type: _BlockType.heading2, content: line.substring(3)));
      } else if (line.startsWith('# ')) {
        blocks.add(_Block(type: _BlockType.heading1, content: line.substring(2)));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        blocks.add(_Block(type: _BlockType.bullet, content: line.substring(2)));
      } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final content = line.replaceFirst(RegExp(r'^\d+\. '), '');
        blocks.add(_Block(type: _BlockType.bullet, content: content));
      } else {
        blocks.add(_Block(type: _BlockType.paragraph, content: line));
      }
    }
  }
}


class _HeadingWidget extends StatelessWidget {
  final String text;
  final int level;

  const _HeadingWidget({required this.text, required this.level});

  @override
  Widget build(BuildContext context) {
    final style = switch (level) {
      1 => const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
      2 => const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
      _ => const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          height: 1.3,
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: _InlineText(text: text, baseStyle: style),
    );
  }
}


class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: SizedBox(
              width: 14,
              child: Text(
                '•',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ),
          ),
          Expanded(child: _InlineText(text: text)),
        ],
      ),
    );
  }
}


class _InlineText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const _InlineText({required this.text, this.baseStyle});

  static const _defaultStyle = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: AppTheme.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final base = baseStyle ?? _defaultStyle;
    return Text.rich(
      TextSpan(children: _buildSpans(text, base)),
      style: base,
    );
  }

  List<InlineSpan> _buildSpans(String input, TextStyle base) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`([^`]+)`');
    int cursor = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: input.substring(cursor, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: base.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.codeBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.group(3)!,
              style: AppTheme.codeStyle.copyWith(fontSize: 12),
            ),
          ),
        ));
      }

      cursor = match.end;
    }

    if (cursor < input.length) {
      spans.add(TextSpan(text: input.substring(cursor)));
    }

    return spans;
  }
}


class _CodeBlock extends StatelessWidget {
  final String code;
  final String language;

  const _CodeBlock({required this.code, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.codeBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  language.isEmpty ? 'code' : language.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF6C7086),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code.trim()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 13, color: Color(0xFF6C7086)),
                      Gap(4),
                      Text(
                        'Copy',
                        style: TextStyle(color: Color(0xFF6C7086), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF313244), height: 1, thickness: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Text(code.trim(), style: AppTheme.codeStyle),
          ),
        ],
      ),
    );
  }
}