import 'dart:io';

void main ()
{
  print("Enter number : ");
  int num = int.parse((stdin.readLineSync().toString()));
  int fact = 1;

  for(int i=1;i<=num;i++)
    {
      fact = fact * i;
    }
  print("Factorial is : $fact");

}
