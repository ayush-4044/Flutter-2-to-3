import 'dart:io';

void main()
{
  print("Enter your choice : ");
  int choice = int.parse(stdin.readLineSync().toString());

  switch(choice)
  {
    case 1 : print("Your language is English");
    case 2 : print("Your language is Hindi");
    case 3 : print("Your language is Gujrati");
    default : print("Invalid choice");
  }
}