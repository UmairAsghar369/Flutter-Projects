void main() {
  // operations in dart list
  List<String> names = ['UMAIR', 'Ali', 'Umar'];
  List<String> name2 = ['aaa', 'bbb', 'ccc'];

  names.add('zain');
  names.insert(3, 'UMAIR');
  names.addAll(['UMAIR', 'Ali', 'Umar']);
  names.insertAll(5, ['UMAIR', 'Haseeb', 'Umar']);
  print(names.indexOf('UMAIR'));
  names.forEach((e) => print(e));
  names.remove('UMAIR');
  names.removeLast();
  names.removeAt(4);
  names.removeRange(0, 3);
  // Combined list
  List<String> combinedList = [...names, ...name2];
  print(names);
  print(combinedList);
  // Use of where in dart list
  List<int> numbers = [2, 4, 6, 8, 10, 11, 12, 13, 14];
  List<int> even = numbers.where((e) => e.isEven).toList();
  print(even);
}
//
                                     // 3
//  import 'dart:math';
//
// void main() {
//   //Write Program to convert feet to metres and metres into KM.
//   double feet = 10;
//   double meter = feet * 0.3048;
//   print('The value in meters is $meter');
//   double km = meter / 1000;
//   print('The value in km is $km');
//
//   // celcius to fahrenheit
//   double cal = 30;
//   double fah = (cal * 9 / 5) + 32;
//   print('The value in fahrenheit is $fah');
//
//   double fahs = 30;
//   double calc = (fahs - 32) * 5 / 9;
//   print('The value in celcius is $calc');
//
//   // Area of a circle
//   double radius = 5;
//
//   double area = pi * radius * radius;
//   print('The area of a circle is $area');
//
//   // area of a square
//
//   double area1 = pi*radius*radius;
//   print('The area of a circle is $area1');
//
// // area of a square
//   double side = 4;
//
//   double areaofsq = side * side;
//
//   print("Area of Square: $areaofsq");
//
//
//   // area of a rectangle
//
// // area of a rectangle
//
//   double length = 5;
//   double width = 4;
//   double areaofrec = length * width;
//   print("Area of Rectangle: $areaofrec");
//
//   // even and odd number check
//   int number = 5;
//   if (number % 2 == 0) {
//     print("The number is even");
//   } else {
//     print('the number is odd');
//   }
//   // the letter is consonent or vowel
//   String name = 'a';
//   if ('aeiou'.contains(name)) {
//     print('The letter is vowel');
//   } else {
//     print('The letter is consonant');
//   }
//   // check the number is positive or negative
//   int num = 1;
//   if (num >= 0) {
//     print('The number is positive');
//   } else {
//     print('The number is negative');
//   }
//   // 100 times name
//
//   String name1 = 'Ayan';
//
//   for (int i = 1; i <= 100; i++) {
//     print('$i : $name1 ');
//   }
//   // Sum of natural numbers
//   int sum = 0;
//   for (int i = 1; i <= 100; i++) {
//     sum += i;
//   }
//   print('The sum of natural numbers is $sum');
//
//
// // table of 5
//   int n = 5;
//   for (int i = 1; i <=10; i++) {
//     int result = n * i;
//     print('$n * $i = $result');
//   }
// //table from one to nine
//
//   for (int i = 1; i <= 9; i++) {
//     print("Table of $i");
//
//     for (int j = 1; j <= 10; j++) {
//       int result = i * j;
//       print("$i x $j = $result");
//     }
//
//     print("------------");
//   }
//   for (int i = 1; i <= 100;i++){
//     if(i == 41){
//       continue;
//     }
//     print(i);
//   }
//   display();
//   print(displays());
// }
// void display(){
//   print('UMAIR');
// }
// String displays(){
//   return 'umair';
// }
                                    // 4
// void main() {
//   Map<String, dynamic> map = {
//     'name': 'Ayan',
//     'age': 22,
//     'class': 'SP24-BCS-021',
//   };
//   print(map['name']);
//   print(map['age']);
//   print(map['class']);
//   map['age'] = 21;
//   print(map);
//   print(map.keys);
//   print(map.values);
//
//
//
//   Map<String, dynamic> book = {
//     'title': 'Misson Mangal',
//     'author': 'Kuber Singh',
//     'page': 233
//   };
//
//   for(MapEntry book in book.entries){
//     print('Key is ${book.key}, value ${book.value}');
//   }
//   // Loop Through For Each
//   book.forEach((key,value)=> print('Key is $key and value is $value'));
//
//
//   Map<String, double> mathMarks = {
//     "ram": 30,
//     "mark": 32,
//     "harry": 88,
//     "raj": 69,
//     "john": 15,
//   };
//   mathMarks.removeWhere((key, value) => value < 32);
//   print(mathMarks);
//
// }
                              // 5
// void main() {
//   String grade = "A";
//
//   switch (grade) {
//     case "A":
//       print("Excellent");
//       break;
//
//     case "B":
//       print("Good");
//       break;
//
//     case "C":
//       print("Average");
//       break;
//
//     default:
//       print("Fail");
//   }
// }