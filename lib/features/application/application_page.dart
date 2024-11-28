


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/values/colors.dart';
import '../../common/widgets/application_widgets.dart';
import 'bloc/app_bloc.dart';
import 'bloc/app_events.dart';
import 'bloc/app_states.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  int _index = 0;
  
  get barItems => null;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: BlocConsumer<AppBloc, AppState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return SafeArea(
                  child: Scaffold(
                backgroundColor: Colors.white,
                body: buildPage(state.index),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.h),
                          topRight: Radius.circular(20.h)),
                      // border: Border(
                      //   top: BorderSide(
                      //     color: Colors.grey.shade300
                      //   )
                      // ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 1,
                            blurRadius: 1)
                      ]),
                  child: BottomNavigationBar(
                      elevation: 0,
                      currentIndex: state.index,
                      type: BottomNavigationBarType.fixed,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      selectedItemColor: AppColors.primaryElement,
                      unselectedItemColor: AppColors.primaryFourthElementText,
                      backgroundColor: Colors.white,
                      onTap: (value) {
                      context.read<AppBloc>().add(TriggerAppEvent(index: value));
                      },
                      items: [
                        ...barItems.map(
                          (e) => BottomNavigationBarItem(
                              activeIcon: SizedBox(
                                  height: 15.w,
                                  width: 15.w,
                                  child: Image.asset(
                                    e.icon,
                                    color: AppColors.primaryElement,
                                  )),
                              icon: SizedBox(
                                height: 15.w,
                                width: 15.w,
                                child: Image.asset(e.icon),
                              ),
                              label: e.label),
                        )
                      ]),
                ),
              ));
            },
          ),
        );
      },
    );
  }
}
