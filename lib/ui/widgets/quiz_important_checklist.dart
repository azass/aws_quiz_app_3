import 'package:flutter/material.dart';

class QuizImportantChecklist extends StatelessWidget {
  final Future<void> Function() onSubmit;
  final bool submitting;

  const QuizImportantChecklist({
    super.key,
    required this.onSubmit,
    required this.submitting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: submitting ? null : onSubmit,
          icon: submitting
              ? const SizedBox.square(
                  dimension: 16.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(submitting ? '送信中...' : '状態を送信'),
        ),
      ),
    );
  }
}
