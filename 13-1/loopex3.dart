import 'dart:io';

void main()
{
  print("Enter number : ");
  int num = int.parse((stdin.readLineSync().toString()));
  int fdigit = 0;
  int ldigit = 0;

  ldigit = num%10;
  while(num>0)
  {
    if(num>9)
      {
        num = num~/10;
      }
    else{
      fdigit = num;
      num = num~/10;
    }
  }
  int sum = fdigit+ldigit;
  print("The sum of first & last digit is : $sum");
}