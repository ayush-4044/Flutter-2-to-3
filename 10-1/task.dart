import 'dart:io';

void main()
{
  print("Enter marks of English : ");
  int marks1 = int.parse(stdin.readLineSync().toString());

  print("Enter marks of Gujrati : ");
  int marks2 = int.parse(stdin.readLineSync().toString());

  print("Enter marks of Hindi : ");
  int marks3 = int.parse(stdin.readLineSync().toString());

  print("Enter marks of Science : ");
  int marks4 = int.parse(stdin.readLineSync().toString());

  print("Enter marks of Maths : ");
  int marks5 = int.parse(stdin.readLineSync().toString());

  int total = marks1+marks2+marks3+marks4+marks5;
  print("Your total is : $total");

  var per = total/5;
  print("Your percentage is : $per");

  if(per>=90)
    {
      print("A Grade");
    }
  else if(per>=80)
  {
  print("B Grade");
  }
  else if(per>=70)
  {
    print("C Grade");
  }
  else if(per>=60)
  {
    print("D Grade");
  }
  else
    {
      print("Fail");
    }

}