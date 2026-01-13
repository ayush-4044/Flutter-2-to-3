import 'dart:io';

void main()
{
  print("Enter number : ");
  var num = int.parse(stdin.readLineSync().toString());

  for(int i=1;i<=10;i++)
    {
      int ans = num*i;
      print("$num * $i = $ans");
    }

}