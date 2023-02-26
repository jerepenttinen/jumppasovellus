import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jumpat/data/provider.dart';
import 'package:jumpat/data/tables.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';

Future<Exercise?> selectExerciseDialog(BuildContext context) async {
  final t = AppLocalizations.of(context)!;
  return showDialog<Exercise>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.exercise),
      content: const SelectExercise(),
    ),
  );
}

class SelectExercise extends ConsumerWidget {
  const SelectExercise({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTerm = BehaviorSubject<String>();

    void search(String term) => searchTerm.add(term);

    final exercises = searchTerm
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((value) async* {
      yield await ref.read(searchExercisesProvider(value).future);
    });

    final canCreate =
        searchTerm.debounceTime(const Duration(milliseconds: 300)).switchMap(
      (value) async* {
        yield value.length > 2 &&
            !await ref.read(existsExerciseProvider(value).future);
      },
    );

    final t = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          decoration: InputDecoration(hintText: t.exerciseNameHint),
          onChanged: search,
          onSubmitted: (value) async {
            final exercises =
                await ref.read(SearchExercisesProvider(value).future);
            final exercise = exercises.isEmpty
                ? await ref
                    .read(createExerciseProvider(searchTerm.value).future)
                : exercises.first;

            if (context.mounted) {
              Navigator.of(context).pop(exercise);
            }
          },
        ),
        StreamBuilder(
          stream: exercises,
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            return Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: data
                      .map((e) => _createExerciseListItem(context, e))
                      .toList(),
                ),
              ),
            );
          },
        ),
        StreamBuilder(
          stream: canCreate,
          builder: (context, snapshot) {
            final canCreate = snapshot.data ?? false;

            if (canCreate) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    final exercise = await ref
                        .read(createExerciseProvider(searchTerm.value).future);

                    if (context.mounted) {
                      Navigator.of(context).pop(exercise);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      t.createExerciseButton(searchTerm.value),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  Widget _createExerciseListItem(BuildContext context, Exercise exercise) {
    return ListTile(
      title: Text(exercise.name),
      onTap: () {
        Navigator.of(context).pop(exercise);
      },
    );
  }
}
