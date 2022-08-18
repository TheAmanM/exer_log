import 'package:exerlog/Bloc/exercise_bloc.dart';
import 'package:exerlog/Bloc/user_bloc.dart';
import 'package:exerlog/Bloc/workout_bloc.dart';
import 'package:exerlog/Models/exercise.dart';
import 'package:exerlog/Models/sets.dart';
import 'package:exerlog/Models/workout.dart';
import 'package:exerlog/Models/workout_data.dart';
import 'package:exerlog/UI/calendar/view/calendar_page.dart';
import 'package:exerlog/UI/exercise/add_exercise_widget.dart';
import 'package:exerlog/UI/exercise/add_new_exercise_alert.dart';
import 'package:exerlog/UI/exercise/exercise_card.dart';
import 'package:exerlog/UI/exercise/totals_widget.dart';
import 'package:exerlog/UI/gradient_border_button.dart';
import 'package:exerlog/UI/workout/add_new_workout_alert.dart';
import 'package:exerlog/UI/workout/save_workout_dialog.dart';
import 'package:exerlog/UI/workout/workout_name_selection_widget.dart';
import 'package:exerlog/UI/workout/workout_toatals_widget.dart';
import 'package:exerlog/src/core/theme/app_theme.dart';
import 'package:exerlog/src/widgets/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import '../../src/widgets/gradient_button.dart';
import '../global.dart';

class WorkoutPage extends StatefulWidget {
  Workout? workout;
  WorkoutPage(this.workout);

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late WorkoutTotalsWidget workoutTotalsWidget;
  late WorkoutData workoutData;
  String exerciseName = '';
  late bool firstLoad;
  List workoutList = [];

  @override
  void initState() {
    print("init");
    if (widget.workout == null) {
      firstLoad = true;
      String id = '';
      try {
        id = widget.workout!.id!;
      } catch (Exception) {}
      widget.workout = new Workout([], '', '', 0, '', '', false, 0, 0.0, 0);
      widget.workout!.id = id;
      workoutData = new WorkoutData(widget.workout!, new WorkoutTotals(0, 0, 0, 0, 0), updateTotals);
    } else {
      firstLoad = false;
      workoutData = new WorkoutData(widget.workout!, new WorkoutTotals(0, 0, 0, 0, 0), updateTotals);
      addExercises(widget.workout);
    }
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      builder: (context, theme) {
        screenHeight = MediaQuery.of(context).size.height;
        screenWidth = MediaQuery.of(context).size.width;
        workoutTotalsWidget = new WorkoutTotalsWidget(totals: workoutData.totals);
        return firstLoad
            ? FutureBuilder(
                future: getWorkoutTemplates(),
                builder: (BuildContext context, AsyncSnapshot<List<Workout>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error"),
                      );
                    } else {
                      if (snapshot.data!.isEmpty) {
                        firstLoad = false;
                        Future.delayed(Duration.zero, () => showAlertDialogExercise(context));
                        return getPage(theme);
                      } else {
                        firstLoad = false;
                        workoutList = snapshot.data!;
                        Future.delayed(Duration.zero, () => showAlertDialogWorkout(context));
                        return getPage(theme);
                      }
                    }
                  }
                })
            : getPage(theme);
      },
    );
  }

  Widget getPage(AppTheme theme) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorTheme.primaryColor,
        child: Icon(
          Icons.add,
          color: theme.colorTheme.backgroundColorVariation,
        ),
        onPressed: () {
          showAlertDialogExercise(context);
        },
      ),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: theme.colorTheme.backgroundColorVariation,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CalendarPage(),
              ),
            );
          },
          color: theme.colorTheme.primaryColor,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 5),
            height: 30,
            width: 30,
            child: FloatingActionButton(
              backgroundColor: theme.colorTheme.primaryColor,
              onPressed: () {
                for (Exercise exercise in workoutData.workout.exercises) {
                  for (int i = 0; i < exercise.sets.length; i++) {
                    if (exercise.sets[i].reps == 0) {
                      exercise.sets.remove(exercise.sets[i]);
                    }
                  }
                  if (exercise.sets.length == 0) {
                    workoutData.workout.exercises.remove(exercise);
                  }
                }
                if (workoutData.workout.exercises.length > 0) {
                  showSaveWorkoutAlertDialog(context);
                }
              },
              child: Icon(
                Icons.done,
                color: theme.colorTheme.backgroundColorVariation,
              ),
            ),
          ),
        ],
      ),
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: firstLoad
            ? Container(
                color: theme.colorTheme.backgroundColorVariation,
              )
            : GestureDetector(
                child: Container(
                  color: theme.colorTheme.backgroundColorVariation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WorkoutTotalsWidget(
                        totals: workoutData.totals,
                      ),
                      Expanded(
                        child: ListView(
                          addAutomaticKeepAlives: true,
                          children: workoutData.exerciseWidgets,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  setExercisename(name) {
    exerciseName = name;
  }

  setWorkout(name, template) {
    workoutData.workout.name = name;
    workoutData.workout.template = template;
  }

  updateTotals(new_workout) {
    setState(() {
      //firstLoad = false;
      //workoutData.workout = new_workout;
      //widget.workout = new_workout;
      //print(workoutData.exerciseWidgets[0].setList.length);
    });
  }

  addExercise() {
    if (exerciseName != '') {
      workoutData.addExercise(new Exercise(exerciseName, [], [], 0, 0, 0.0));

      // workoutData.setExerciseWidgets();
      Navigator.pop(context);
    }
  }

  showAlertDialogExercise(BuildContext context) {
    ExerciseNameSelectionWidget exerciseNameSelectionWidget = new ExerciseNameSelectionWidget(
      setExercisename: setExercisename,
    );
    // set up the button
    RaisedGradientButton okButton = RaisedGradientButton(
      radius: 30,
      child: Text(
        "ADD",
        style: buttonTextSmall,
      ),
      onPressed: addExercise,
    );

    // set up the AlertDialog
    AddExerciseAlert alert = AddExerciseAlert(okButton, exerciseNameSelectionWidget);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  createNewSet(sets, id) {}

  showSaveWorkoutAlertDialog(BuildContext context) {
    RaisedGradientButton okButton = RaisedGradientButton(
      radius: 30,
      child: Text(
        "SAVE",
        style: buttonTextSmall,
      ),
      onPressed: () {
        saveWorkout(workoutData.workout);
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CalendarPage(),
          ),
        );
      },
    );

    // set up the AlertDialog
    SaveWorkoutAlert alert = SaveWorkoutAlert(okButton, setWorkout);

    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  setWorkoutName(name) {
    workoutData.workout.name = name;
  }

  addExercises(new_workout) {
    setState(() {
      WorkoutData newWorkoutData = new WorkoutData(new_workout, new WorkoutTotals(0, 0, 0, 0, 0), updateTotals);
      firstLoad = false;
      workoutData = newWorkoutData;
      widget.workout = newWorkoutData.workout;
      //print(workoutData.workout.exercises[0]);
    });
  }

  showAlertDialogWorkout(BuildContext context) {
    WorkoutTemplateSelectionWidget workoutTemplateSelectionWidget = new WorkoutTemplateSelectionWidget(
      setWorkout: addExercises,
      workoutList: workoutList,
    );
    RaisedGradientButton okButton = RaisedGradientButton(
      radius: 30,
      child: Text(
        "START",
        style: buttonTextSmall,
      ),
      onPressed: () {
        setState(() {
          firstLoad = false;
        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AddWorkoutAlert alert = AddWorkoutAlert(okButton, workoutTemplateSelectionWidget);

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
