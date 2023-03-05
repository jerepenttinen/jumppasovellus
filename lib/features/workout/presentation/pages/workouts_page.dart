import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jumpat/app_router.dart';
import 'package:jumpat/features/workout/domain/entities/workout_entity.dart';
import 'package:jumpat/features/workout/domain/providers/workout.dart';
import 'package:jumpat/features/workout/presentation/widgets/choose_template_dialog.dart';
import 'package:jumpat/features/workout/presentation/widgets/workout_card.dart';

class WorkoutsPage extends ConsumerWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.name),
      ),
      body: const WorkoutsList(),
      floatingActionButton: const WorkoutsFab(),
      drawer: const WorkoutsDrawer(),
    );
  }
}

class WorkoutsList extends ConsumerWidget {
  const WorkoutsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutsProvider);
    return workouts.when(
      error: (error, stackTrace) => Center(child: Text('$error')),
      loading: () => const Center(child: CircularProgressIndicator()),
      data: (workouts) => ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) => WorkoutCard(
          workoutId: workouts[index].id,
        ),
      ),
    );
  }
}

class WorkoutsDrawer extends StatelessWidget {
  const WorkoutsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text(t.templates),
              leading: const Icon(Icons.list_alt),
              onTap: () {
                Navigator.pop(context);
                context.router.push(const TemplatesRoute());
              },
            ),
            ListTile(
              title: Text(t.exercises),
              leading: const Icon(Icons.fitness_center),
              onTap: () {
                Navigator.pop(context);
                context.router.push(const ExercisesRoute());
              },
            ),
            ListTile(
              title: Text(t.backupTitle),
              leading: const Icon(Icons.backup),
              onTap: () {
                Navigator.pop(context);
                context.router.push(const BackupRoute());
              },
            ),
            ListTile(
              title: Text(t.settingsTitle),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                context.router.push(const SettingsRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutsFab extends ConsumerWidget {
  const WorkoutsFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return Wrap(
      direction: Axis.vertical,
      spacing: 16,
      children: [
        FloatingActionButton(
          heroTag: UniqueKey(),
          tooltip: t.useTemplate,
          onPressed: () async {
            final template = await chooseTemplateDialog(context);
            if (template == null) {
              return;
            }

            final workout = await ref
                .read(workoutsProvider.notifier)
                .addFromTemplate(template);

            if (context.mounted) {
              await context.router
                  .push(EditWorkoutRoute(workoutId: workout.id));
            }
          },
          child: const Icon(Icons.control_point_duplicate_rounded),
        ),
        FloatingActionButton(
          heroTag: UniqueKey(),
          tooltip: t.newWorkout,
          child: const Icon(Icons.add),
          onPressed: () async {
            final workout = WorkoutEntity.empty();
            await ref.read(workoutsProvider.notifier).save(workout);
            if (context.mounted) {
              await context.router
                  .push(EditWorkoutRoute(workoutId: workout.id));
            }
          },
        ),
      ],
    );
  }
}
