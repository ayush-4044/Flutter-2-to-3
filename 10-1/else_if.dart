import 'dart:io';

void main()
{
  print("Enter your marks : ");
  int marks = int.parse(stdin.readLineSync().toString());

  if(marks>=70)
    {
      print("Your grade is A");
    }
  else if(marks>=60)
    {
      print("Your grade is B");
    }
  else if(marks>=50)
    {
      print("Your grade is C");
    }
  else if(marks>=35)
    {
      print("Your grade is D");
    }
  else
    {
      print("You are fail");
    }
}