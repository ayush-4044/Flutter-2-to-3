import 'dart:io';

void main()
{
  print("Enter number : ");
  int num = int.parse((stdin.readLineSync().toString()));
  int max = 0;

  while(num>0)
  {
    int rem = num%10;
    if(rem>max)
      {
        max = rem;
      }
    num = num~/10;
  }
  print("The maximum number is : $max");
}