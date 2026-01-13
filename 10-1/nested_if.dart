import 'dart:io';

void main()
{
  print("Enter your age : ");
  int age = int.parse(stdin.readLineSync().toString());

  if(age>=18)
    {
      print("Your eligible to vote");

      if(age>=60)
      {
        print("You are senior citizen");
      }
      else{
        print("You are young age");
      }
    }
  else
    {
      print("You are not eligible to vote");
    }
}