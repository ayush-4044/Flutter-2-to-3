import 'dart:io';

void main()
{
  print("Enter number : ");
  var num = int.parse(stdin.readLineSync().toString());
  int digit;
  int sum=0;
  while(num!=0)
    {
     digit = num%10;
     sum=sum+digit;
     num = (num~/10);

    }
  print("Sum of all digit is : $sum");

}