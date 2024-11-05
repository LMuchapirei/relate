import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils.dart';

// class MonthYearPicker extends StatefulWidget {
//   @override
//   _MonthYearPickerState createState() => _MonthYearPickerState();
// }

// class _MonthYearPickerState extends State<MonthYearPicker> {
//   String? selectedMonth;
//   int selectedYear = 2024;

//   final List<String> months = [
//     "Jan", "Feb", "Mar", "Apr", "May", "Jun",
//     "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
//   ];

//   List<int> years = List.generate(10, (index) => 2024 - index);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10.h),
//       margin: EdgeInsets.all(10.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20.h)
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Select Month & Year",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   childAspectRatio: 2,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                 ),
//                 itemCount: months.length,
//                 itemBuilder: (context, index) {
//                   return ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: selectedMonth == months[index] 
//                           ? Colors.red 
//                           : Colors.grey[300],
                      
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         selectedMonth = months[index];
//                       });
//                     },
//                     child: Text(months[index]),
//                   );
//                 },
//               ),
//             ),
//             DropdownButtonFormField<int>(
//               decoration: const InputDecoration(
//                 labelText: "Year",
//                 border: OutlineInputBorder(),
//               ),
//               value: selectedYear,
//               onChanged: (int? newValue) {
//                 setState(() {
//                   selectedYear = newValue!;
//                 });
//               },
//               items: years.map((year) {
//                 return DropdownMenuItem(
//                   value: year,
//                   child: Text(year.toString()),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 if (selectedMonth != null && selectedYear != null) {
//                   // Handle the update action here
//                   Navigator.pop(context,{"month":selectedMonth,"year":selectedYear}); 
//                 } else {
//                   // Show a message if no month is selected
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Please select a month")),
//                   );
//                 }
//               },
//               child: Text("Update"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MonthYearPicker extends StatefulWidget {
  @override
  _MonthYearPickerState createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  int selectedMonth = 1;
  int selectedYear = 2024;

  final Map<int,String> months = {
    0:"Jan",1:"Feb",2:"Mar",3:"Apr",4:"May",5:"Jun",6:
    "Jul",7:"Aug",8:"Sep",9:"Oct",10:"Nov",11:"Dec"
  };

  List<int> years = List.generate(10, (index) => 2024 - index);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0), // Padding for modal
      margin: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the modal
        borderRadius: BorderRadius.circular(20.h),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    selectedYear--; // Decrease the year
                  });
                },
              ),
              Text(
                selectedYear.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  setState(() {
                    selectedYear++; // Increase the year
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          // Month selection buttons
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: months.length,
            shrinkWrap: true, // Prevents overflow
            physics: NeverScrollableScrollPhysics(), // Prevents scrolling
            itemBuilder: (context, index) {
              /// change a setting to only 
              final isGreater = isMonthGreaterThanCurrent(index + 1);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: 
                    // isGreater ? 
                    selectedMonth == index
                      ? Colors.red 
                       : Colors.grey[300],//: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.h)
                      )
                ),
                onPressed: () {
                    
                    if(!isGreater){  
                      return;
                    }
                  setState(() {
                    selectedMonth = index;
                  });
                },
                child: Text(
                  months[index]!,
                  style: TextStyle(fontSize: 16.sp,color:selectedMonth == months[index] ? Colors.white : Colors.black ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedMonth != null) {
                // Handle the update action here
                Navigator.pop(context,{"month":selectedMonth,"year":selectedYear}); // Close the modal
                // showDialog(
                //   context: context,
                //   builder: (BuildContext context) {
                //     return AlertDialog(
                //       title: Text("Selected Date"),
                //       content: Text("Month: $selectedMonth\nYear: $selectedYear"),
                //       actions: [
                //         TextButton(
                //           onPressed: () => Navigator.pop(context),
                //           child: Text("OK"),
                //         ),
                //       ],
                //     );
                //   },
                // );
              } else {

              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button color
              padding: EdgeInsets.symmetric(vertical: 12), // Vertical padding for the button
              minimumSize: Size(double.infinity, 0), // Full width button
            ),
            child: Text("Filter",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}