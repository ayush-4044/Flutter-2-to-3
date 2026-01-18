int cal(int a,int b)
{
  return a+b;
}
 cal1(int a,int b)
{
  var c = a+b;
  print(c);
}
cal2()
{
  var a = 3;
  var b = 8;
  var c = a+b;
  return c;

}
cal3()
{
  var a = 7;
  var b = 6;
  var c = a + b;
  print(c);
}

void main()
{

  print(cal(2, 5));
  cal1(5, 6);
  print(cal2());
  cal3();
}