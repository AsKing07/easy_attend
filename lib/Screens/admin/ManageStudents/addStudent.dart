import 'package:easy_attend/Config/styles.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addNewStudent.dart';
import 'package:easy_attend/Screens/admin/ManageStudents/addStudentFromExcel.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AddStudent extends StatefulWidget {
  final void Function() callback;

  const AddStudent({super.key, required this.callback});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  late TabController tabController;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
              // child: Card(
              //     surfaceTintColor: Theme.of(context).cardColor,
              //     color: Theme.of(context).cardColor,
              //     elevation: 8.0,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(15.0),
              //     ),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GFTabBar(
                indicatorColor: AppColors.secondaryColor,
                tabBarColor: Theme.of(context).cardColor,
                width: screenWidth > 600 ? screenWidth / 1.5 : screenWidth,
                tabBarHeight: 58,
                length: 2,
                controller: tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.add),
                    child: Text(
                      "Ajout d'un étudiant",
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.file_upload),
                    child: Text(
                      'Ajout depuis un fichier',
                    ),
                  ),
                ],
              ),
              GFTabBarView(
                controller: tabController,
                children: <Widget>[
                  addNewStudentPage(callback: widget.callback),
                  AddStudentFromExcel(callback: widget.callback),
                ],
              ),
            ],
          ))),
    );
  }
}
