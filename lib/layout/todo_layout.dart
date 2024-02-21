import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../shared/components/components.dart';

class HomeLayout extends StatelessWidget {
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var titleController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
        if (state is AppInsertIntoDatabaseState) {
          Navigator.pop(context);
        }
      }, builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(
              cubit.titles[cubit.curIndex],
            ),
          ),
          body: ConditionalBuilder(
              condition: state is! AppLoadingDatabaseState,
              builder: (context) => cubit.screens[cubit.curIndex],
              fallback: (context) => const Center(
                    child: CircularProgressIndicator(),
                  )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                cubit.insertToDatabase(
                  title: titleController.text,
                  date: dateController.text,
                  time: timeController.text,
                );
              } else {
                scaffoldKey.currentState!
                    .showBottomSheet((context) => Container(
                          color: Colors.grey[200],
                          padding: EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultTextFormField(
                                    TextEditingController: titleController,
                                    TextInputType: TextInputType.text,
                                    validator: (value) {
                                      if (value?.isEmpty ?? false) {
                                        return 'Title must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title),
                                const SizedBox(height: 15),
                                defaultTextFormField(
                                    TextEditingController: timeController,
                                    TextInputType: TextInputType.datetime,
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeController.text =
                                            value?.format(context) ?? "";
                                      });
                                    },
                                    validator: (value) {
                                      if (value?.isEmpty ?? false) {
                                        return 'Time must not be empty';
                                      }
                                    },
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined),
                                const SizedBox(height: 15),
                                defaultTextFormField(
                                    TextEditingController: dateController,
                                    TextInputType: TextInputType.datetime,
                                    validator: (value) {
                                      if (value?.isEmpty ?? false) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      showDatePicker(
                                              keyboardType:
                                                  TextInputType.datetime,
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse("2024-01-01"))
                                          .then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                    label: 'Task Date',
                                    prefix: Icons.calendar_month_outlined),
                              ],
                            ),
                          ),
                        ))
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState(
                      icon: Icons.edit, isShown: false);
                });
                cubit.changeBottomSheetState(icon: Icons.add, isShown: true);
              }
            },
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.curIndex,
            onTap: (index) {
              print(index);
              cubit.changeIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive),
                label: 'Archived',
              ),
            ],
          ),
        );
      }),
    );
  }
}
