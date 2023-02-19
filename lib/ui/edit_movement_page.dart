import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jumpat/data/isar_service.dart';
import 'package:jumpat/data/workout.dart';
import 'package:jumpat/injection.dart';
import 'package:jumpat/ui/routes/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:jumpat/ui/widgets/choose_rep_count_dialog.dart';
import 'package:jumpat/ui/widgets/select_exercise_dialog.dart';

class EditMovementPage extends StatefulWidget {
  const EditMovementPage({required this.movement, super.key});
  final Movement movement;

  @override
  State<EditMovementPage> createState() => _EditMovementPageState();
}

class _EditMovementPageState extends State<EditMovementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movement.exercise.value?.name ?? 'Tuntematon'),
        actions: [
          IconButton(
            onPressed: widget.movement.exercise.value != null
                ? () {
                    context.router.push(
                      ExerciseHistoryRoute(
                        exercise: widget.movement.exercise.value!,
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () async {
              final exercise = await selectExerciseDialog(context);

              if (exercise == null) {
                return;
              }

              setState(() {
                widget.movement.exercise.value = exercise;
              });

              exercise.movements.add(widget.movement);
              await getIt<IsarService>().saveMovement(widget.movement);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _buildSetsList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final count = await chooseRepCountDialog(context, 10);
          if (count == null) {
            return;
          }

          widget.movement.sets = [...widget.movement.sets, count];

          await getIt<IsarService>().saveMovement(widget.movement);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSetsList(BuildContext context) {
    return StreamBuilder(
      stream: getIt<IsarService>().watchMovement(widget.movement),
      builder: (context, snapshot) {
        final sets = snapshot.data?.sets ?? [];
        return ListView.builder(
          itemCount: sets.length,
          itemBuilder: (context, index) {
            return _buildSetsListItem(sets, index);
          },
        );
      },
    );
  }

  Slidable _buildSetsListItem(List<int> sets, int index) {
    final repCount = sets[index];
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            label: 'Muokkaa',
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: Icons.delete,
            onPressed: (context) async {
              final count = await chooseRepCountDialog(context, repCount);
              if (count == null) {
                return;
              }
              final newSets = [...sets];
              newSets[index] = count;
              widget.movement.sets = newSets;

              await getIt<IsarService>().saveMovement(widget.movement);
            },
          )
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.3,
        dismissible: DismissiblePane(
          onDismissed: () async {
            widget.movement.sets = [...sets]..removeAt(index);
            await getIt<IsarService>().saveMovement(widget.movement);
          },
        ),
        children: [
          SlidableAction(
            label: 'Poista',
            backgroundColor: Theme.of(context).colorScheme.error,
            icon: Icons.delete,
            onPressed: (context) async {
              widget.movement.sets = [...sets]..removeAt(index);
              await getIt<IsarService>().saveMovement(widget.movement);
            },
          )
        ],
      ),
      child: ListTile(
        title: Text(repCount.toString()),
      ),
    );
  }
}