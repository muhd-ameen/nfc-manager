// ignore_for_file: avoid_print

import 'package:flutter_nfc_test/model/record.dart';
import 'package:flutter_nfc_test/model/write_record.dart';
import 'package:flutter_nfc_test/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTextModel with ChangeNotifier {
  EditTextModel(this._repo, this.old) {
    if (old == null) return;
    final record = WellknownTextRecord.fromNdef(old!.record);
    textController.text = record.text;
  }

  final Repository _repo;
  final WriteRecord? old;
  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController textController = TextEditingController();

  Future<Object> save() async {
    if (!formKey.currentState!.validate()) throw ('Form is invalid.');

    final record = WellknownTextRecord(
      languageCode: 'en', // todo:
      text: textController.text,
    );

    return _repo.createOrUpdateWriteRecord(WriteRecord(
      id: old?.id,
      record: record.toNdef(),
    ));
  }
}

class EditTextPage extends StatelessWidget {
  const EditTextPage({super.key});

  static Widget withDependency([WriteRecord? record]) =>
      ChangeNotifierProvider<EditTextModel>(
        create: (context) =>
            EditTextModel(Provider.of(context, listen: false), record),
        child: const EditTextPage(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Text'),
      ),
      body: Form(
        key: Provider.of<EditTextModel>(context, listen: false).formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: Provider.of<EditTextModel>(context, listen: false)
                  .textController,
              decoration: const InputDecoration(labelText: 'Text', helperText: ''),
              keyboardType: TextInputType.text,
              validator: (value) =>
                  value?.isNotEmpty != true ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () =>
                  Provider.of<EditTextModel>(context, listen: false)
                      .save()
                      .then((_) => Navigator.pop(context))
                      .catchError((e) => print('=== $e ===')),
            ),
          ],
        ),
      ),
    );
  }
}
