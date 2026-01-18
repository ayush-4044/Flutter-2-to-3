details(var name,{var surname,var email})
{
  if(name!=null)
    {
      print("$name");
    }
  if(surname!=null)
  {
    print("$surname");
  }
  if(email!=null)
  {
    print("$email");
  }
}
void main()
{
  details("Ayush",surname: "Hirpara",email: "a@gmail.com");
  details("Dhaval");
}
