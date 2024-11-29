//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "kod.h"
//---------------------------------------------------------------------------
#pragma resource "*.dfm"
TForm1 *Form1;
void Wyswietl();
bool Kodowanie(bool z);
int JakieK(int x,int y);
bool TargajH();
void Blady(int b,int c);
void WyswietlPoBledach();
void ZatwierdzBlady();
void Wyswietl2(int tmin);
void Blad(int B);
void Dekodowanie(bool jak);
int Sprawdz(int t,int i);
void GenerujTablice();
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
	: TForm(Owner)
{
  Dane.il=7;
  Label34->Caption=IntToStr(pow(2,Dane.il));
  Memo1->Text="";
  Memo2->Text="";
  Memo3->Text="";
  Label40->Caption="";
  Label11->Caption="";
  Label10->Caption="";
  Edit39->Text="111000111000111";
  StatusBar1->SimpleText="WprowadŸ wektor wejœciowy i/lub wielomiany generacyjne.";
  Dane.blad=1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
	char str[150]={0};
    Dane.set=false;
    Dane.n0=4;
    Dane.k=7;
    if ( ((Edit1->Text)!='1')&&((Edit1->Text)!='0') )	Blad(1);
	else 	Dane.G[0][0] = StrToInt (Edit1->Text);
    if ( ((Edit2->Text)!='1')&&((Edit2->Text)!='0') )	Blad(2);
    else 	Dane.G[0][1] = StrToInt (Edit2->Text);
    if ( ((Edit3->Text)!='1')&&((Edit3->Text)!='0') )	Blad(3);
    else 	Dane.G[0][2] = StrToInt (Edit3->Text);
    if ( ((Edit4->Text)!='1')&&((Edit4->Text)!='0') )	Blad(4);
    else 	Dane.G[0][3] = StrToInt (Edit4->Text);
    if ( ((Edit5->Text)!='1')&&((Edit5->Text)!='0') )	Blad(5);
    else	Dane.G[1][0] = StrToInt (Edit5->Text);
	if ( ((Edit6->Text)!='1')&&((Edit6->Text)!='0') )	Blad(6);
    else	Dane.G[1][1] = StrToInt (Edit6->Text);
    if ( ((Edit7->Text)!='1')&&((Edit7->Text)!='0') )	Blad(7);
    else	Dane.G[1][2] = StrToInt (Edit7->Text);
    if ( ((Edit8->Text)!='1')&&((Edit8->Text)!='0') )	Blad(8);
    else	Dane.G[1][3] = StrToInt (Edit8->Text);
    if ( ((Edit9->Text)!='1')&&((Edit9->Text)!='0') )	Blad(9);
    else	Dane.G[2][0] = StrToInt (Edit9->Text);
    if ( ((Edit10->Text)!='1')&&((Edit10->Text)!='0') )	Blad(10);
    else	Dane.G[2][1] = StrToInt (Edit10->Text);
    if ( ((Edit11->Text)!='1')&&((Edit11->Text)!='0') )	Blad(11);
    else	Dane.G[2][2] = StrToInt (Edit11->Text);
    if ( ((Edit12->Text)!='1')&&((Edit12->Text)!='0') )	Blad(12);
    else	Dane.G[2][3] = StrToInt (Edit12->Text);
    if ( ((Edit13->Text)!='1')&&((Edit13->Text)!='0') )	Blad(13);
    else 	Dane.G[3][0] = StrToInt (Edit13->Text);
    if ( ((Edit14->Text)!='1')&&((Edit14->Text)!='0') )	Blad(14);
    else 	Dane.G[3][1] = StrToInt (Edit14->Text);
    if ( ((Edit15->Text)!='1')&&((Edit15->Text)!='0') )	Blad(15);
    else	Dane.G[3][2] = StrToInt (Edit15->Text);
    if ( ((Edit16->Text)!='1')&&((Edit16->Text)!='0') )	Blad(16);
    else 	Dane.G[3][3] = StrToInt (Edit16->Text);
    if ( ((Edit17->Text)!='1')&&((Edit17->Text)!='0') )	Blad(17);
    else	Dane.G[4][0] = StrToInt (Edit17->Text);
    if ( ((Edit18->Text)!='1')&&((Edit18->Text)!='0') )	Blad(18);
    else	Dane.G[4][1] = StrToInt (Edit18->Text);
    if ( ((Edit19->Text)!='1')&&((Edit19->Text)!='0') )	Blad(19);
    else	Dane.G[4][2] = StrToInt (Edit19->Text);
    if ( ((Edit20->Text)!='1')&&((Edit20->Text)!='0') )	Blad(20);
    else	Dane.G[4][3] = StrToInt (Edit20->Text);
    if ( ((Edit21->Text)!='1')&&((Edit21->Text)!='0') )	Blad(21);
    else	Dane.G[5][0] = StrToInt (Edit21->Text);
    if ( ((Edit22->Text)!='1')&&((Edit22->Text)!='0') )	Blad(22);
    else	Dane.G[5][1] = StrToInt (Edit22->Text);
    if ( ((Edit23->Text)!='1')&&((Edit23->Text)!='0') )	Blad(23);
    else	Dane.G[5][2] = StrToInt (Edit23->Text);
    if ( ((Edit24->Text)!='1')&&((Edit24->Text)!='0') )	Blad(24);
    else	Dane.G[5][3] = StrToInt (Edit24->Text);
    if ( ((Edit25->Text)!='1')&&((Edit25->Text)!='0') )	Blad(25);
    else 	Dane.G[6][0] = StrToInt (Edit25->Text);
    if ( ((Edit26->Text)!='1')&&((Edit26->Text)!='0') )	Blad(26);
    else	Dane.G[6][1] = StrToInt (Edit26->Text);
    if ( ((Edit27->Text)!='1')&&((Edit27->Text)!='0') )	Blad(27);
    else	Dane.G[6][2] = StrToInt (Edit27->Text);
    if ( ((Edit28->Text)!='1')&&((Edit28->Text)!='0') )	Blad(28);
    else	Dane.G[6][3] = StrToInt (Edit28->Text);

    for (int a=0;a<=4;a++) Dane.G[11][a]=0;

    if (!TargajH())
    	{
        	ShowMessage("B³¹d w polu wprowadzania s³owa wejœciowego !   Nale¿y wprowadzaæ 0 lub 1 ! , max. d³ugoœæ wektora wejœciowego :100 bitów !                     DANYCH NIE ZATWIERDZONO .");
 		}
    else
    	{
Label10->Caption="Dane wprowadzone poprawnie.          Wciœnij przycisk Koduj.";
sprintf(str,"!!Parametry kodu : (d³ug. s³owa wyj.)n=%i ,(d³ug. s³owa wej.)j=%i ,(iloœæ wielominów)k=%i ,(d³ugoœæ wielom.)n0=%i.",(Dane.i*Dane.n0),Dane.j,Dane.k,Dane.n0);
            StatusBar1->SimpleText=str;
        }
Dane.n=Form1->Dane.i*Form1->Dane.n0;
}
//---------------------------------------------------------------------------
void Blad(int B)
{
	char c[70];
    sprintf(c,"B³¹d w polu edycji s³owa generuj¹cego nr %i. Danych nie zatwierdzono .",B);
 	ShowMessage(c);
}
//-----------000000000==============
void __fastcall TForm1::Button2Click(TObject *Sender)
{
 Closeprg->ShowModal();
 if (Closeprg->CloseP==true) Close();
}
//---------------------------------------------------------------------------
void Wyswietl()
{
 char str[405]={0};
 char s[1];
 for (int a=0;a<(Form1->Dane.n);a++)
    {
    	sprintf(s,"%x",Form1->Dane.s[a]);
        StrCat(str,s);
    }
 Form1->Memo1->Text=str;
}
void WyswietlPoBledach()
{
 char str[405]={0};
 char s[1];
 for (int a=0;a<(Form1->Dane.n);a++)
    {
    	sprintf(s,"%x",Form1->Dane.s[a]);
        StrCat(str,s);
    }
 Form1->Memo2->Text=str;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button4Click(TObject *Sender)
{
 char str[150];
 if (Dane.set==true)
 	return;
 else Dane.set=true;
 if (!Kodowanie(false))
 	Label10->Caption="B³¹d w kodowaniu !!!";
 else
   {
 	Label10->Caption="";
  }
 Wyswietl();
 sprintf(str,"Parametry kodu : (d³ug. s³owa wyj.)n=%i ,(d³ug. s³owa wej.)j=%i ,(iloœæ wielominów)k=%i ,(d³ugoœæ wielom.)n0=%i.",Dane.n,Dane.j,Dane.k,Dane.n0);
 StatusBar1->SimpleText=str;
 WyswietlPoBledach();
}
bool Kodowanie(bool z)
{
  int nn=0,ss=0;
  for (int xx=0;xx<=(Form1->Dane.i-1);xx++)
	{
    	for (int ll=0;ll<=(Form1->Dane.n0-1);ll++)
    		{
         		for (int yy=0;yy<=(Form1->Dane.j-1);yy++)
            		{
					if (z==false)  ss=((Form1->Dane.G[JakieK(xx,yy)][ll]*Form1->Dane.h[yy])^ss);
                    else           ss=((Form1->Dane.G[JakieK(xx,yy)][ll]*Form1->Dane.sprwe[yy])^ss);
                    }
              if (z==false) Form1->Dane.s[nn]=ss;
              else          Form1->Dane.sprwy[nn]=ss;
              ss=0;
          	  nn++;
        	}
	}
  return(true);
}
int JakieK(int x,int y)
{
	if((Form1->Dane.k-1+y-x)<0)
	return(11);
	else
	{
    	if ((x-y)<0)
    		return(11);
      	else
        	return(x-y);
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button5Click(TObject *Sender)
{
	AboutBox->ShowModal();
}
//---------------H--------------------------------------
bool TargajH()
{
  char str[101];
  sprintf(str,"%s",Form1->Edit39->Text);
  Form1->Dane.j=Form1->Dane.i=StrLen(str);
  if (Form1->Dane.j>100)
    {
    	Form1->Dane.j=0;
        Form1->Dane.i=0;
    	return(false);
    }
  for(int ii=0;ii<=((Form1->Dane.j)-1);ii++)
  {
  	if ((str[ii]!='1')&&(str[ii]!='0'))
      	{
            Form1->Dane.j=0;
	        Form1->Dane.i=0;
            Form1->Edit39->Text="B³¹d!!! - z³e h";
        	return(false);
        }
    else
    	Form1->Dane.h[ii]=StrToInt(str[ii]);
  }
  return(true);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Kodowanie1Click(TObject *Sender)
{
 TabbedNotebook1->ActivePage="Kodowanie";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Bdy1Click(TObject *Sender)
{
 TabbedNotebook1->ActivePage="Wprowadzanie b³êdów";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Dekodowanie1Click(TObject *Sender)
{
TabbedNotebook1->ActivePage="Dekodowanie";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Opcje1Click(TObject *Sender)
{
TabbedNotebook1->ActivePage="Opcje";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::RadioButton1Click(TObject *Sender)
{
 if (RadioButton1->Checked)
      RadioButton2->Checked=false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::RadioButton2Click(TObject *Sender)
{
 if (RadioButton2->Checked)
      RadioButton1->Checked=false;
}
//---------------------------------------------------------------------------
void ZatwierdzBlady()
{
char s[5];
if (Form1->RadioButton1->Checked)
	{
    	switch (Form1->Dane.blad)
        {
            case 1:                                  //dane procentowe
            	Blady(Form1->TrackBar1->Position,1);
                break;
            case 2:
                Blady(Form1->TrackBar2->Position,1);
                break;
            case 3:
            	Blady(Form1->TrackBar3->Position,1);
				break;
        }
    }
else
    {
        switch (Form1->Dane.blad)
        {
            case 1:
                sprintf(s,"%s",Form1->Edit29->Text);
                if ( (StrLen(s)>2) || (isalpha(s[0])) || (isalpha(s[1])) )
                	{
                		ShowMessage("B³¹d w oknie wprowadzania danych liczbowych nr 1 !!!");
                    	return;
                	}
                break;
        	case 2:
                sprintf(s,"%s",Form1->Edit30->Text);
                if ( (StrLen(s)>2) || (isalpha(s[0])) || (isalpha(s[1])) )
                	{
                		ShowMessage("B³¹d w oknie wprowadzania danych liczbowych nr 2 !!!");
                    	return;
                	}
                break;
            case 3:
                sprintf(s,"%s",Form1->Edit31->Text);
                if ( (StrLen(s)>2) || (isalpha(s[0])) || (isalpha(s[1])) )
                	{
                		ShowMessage("B³¹d w oknie wprowadzania danych liczbowych nr 3 !!!");
                    	return;
                	}
               	break;
        }
        if (StrToInt(s)>Form1->Dane.n)
        	{
            	ShowMessage("Wprowadzona iloœæ b³êdów nie mo¿e byæ wiêksza od liczby bitów wyjœciowych !!!");
        		return;
            }
        else
        	Blady(StrToInt(s),0);
    }
}
//---------------------------------------------------------------------------

void Blady(int b,int c)
{
  int praw=0,x=0,cc=0;			//prawdopodobieñstwo wystapienia bledu w pojedynczym bicie
  char s[100];
  if ( (Form1->Dane.n<=0) || (b==0) )
        {
  			return;
        }
  if (c==0)      					//dane liczbowe
  	{
        switch (Form1->Dane.blad)
        {
    		case 1:
            	{
                	for (int a=0;a<(Form1->Dane.n);a++)
                 		{
                        	praw=(b*100)/(Form1->Dane.n-a);
                     		if (praw>=random(150))
                        		{
                                	Form1->Dane.s[a]=!(Form1->Dane.s[a]);
									x++;
	                                if (x>=b)
                                    	{
        	                        		sprintf(s,"Wprowadzono b³êdów pojedynczych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
					                		Form1->Label11->Caption=s;
                                            Form1->Label40->Caption=s;
                                            return;
                                        }
									a++;
                		       	}
                    	}
                     sprintf(s,"Wprowadzono b³êdów pojedynczych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
                     Form1->Label11->Caption=s;
                     Form1->Label40->Caption=s;
                     return;
                }
        		break;
        	case 2:
                {
                	for (int a=0;a<(Form1->Dane.n);a++)
                 		{
							praw=(b*100)/(Form1->Dane.n-a);
                     		if (praw>=random(300))
                        		{
                                    for (int c=0;( (c<b) && (a<Form1->Dane.n) );c++)
                                      {
	                                	Form1->Dane.s[a]=!(Form1->Dane.s[a]);
                                        a++;
                                        x=c+1;
                                      }
                                    sprintf(s,"Wprowadzono b³êdów seryjnych : %i , czyli %i%%",x,(x*100/(Form1->Dane.n)));
			                		Form1->Label11->Caption=s;
                                    Form1->Label40->Caption=s;
               	                    return;
                		       	}
                    	}
                       sprintf(s,"Wprowadzono b³êdów seryjnych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
                       Form1->Label11->Caption=s;
                       Form1->Label40->Caption=s;
                       return;
                }
	        case 3:
           		{
                	for (int a=0;a<(Form1->Dane.n);a++)
                 		{
							praw=(b*100)/(Form1->Dane.n-a);
                     		if (praw>=random(150))
                        		{
                                	Form1->Dane.s[a]=!(Form1->Dane.s[a]);
									x++;
	                                if (x>=b)
                                    	{
        	                        		sprintf(s,"Wprowadzono b³êdów losowych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
					                		Form1->Label11->Caption=s;
                                            Form1->Label40->Caption=s;
                                            return;
                                        }
                		       	}
                    	}
                    sprintf(s,"Wprowadzono b³êdów losowych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
                    Form1->Label11->Caption=s;
                    Form1->Label40->Caption=s;
                    return;
                }
    	    	break;
    	}
    }
  else  				       	//dane procentowe
  	{
        switch (b)
        {
        	case 0: praw=0; break;
            case 1: praw=3; break;
            case 2: praw=5; break;
            case 3: praw=8; break;
            case 4: praw=10; break;
            case 5: praw=15; break;
            case 6: praw=20; break;
            case 7: praw=25; break;
            case 8: praw=30; break;
            case 9: praw=35; break;
            case 10: praw=40; break;
        }
      	switch (Form1->Dane.blad)
        {
    	 	case 1:
            	{
					b=(praw*Form1->Dane.n)/100;
                	for (int a=0;a<(Form1->Dane.n);a++)
                 		{
                        	praw=(b*100)/(Form1->Dane.n-a);
                     		if (praw>=random(150))
                        		{
                                	Form1->Dane.s[a]=!(Form1->Dane.s[a]);
									x++;
	                                if (x>=b)
                                    	{
        	                        		sprintf(s,"Wprowadzono b³êdów pojedynczych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
					                		Form1->Label11->Caption=s;
                                            Form1->Label40->Caption=s;
                                            return;
                                        }
                                    a++;
                		       	}
                    	}
                    sprintf(s,"Wprowadzono b³êdów pojedynczych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
               		Form1->Label11->Caption=s;
                    Form1->Label40->Caption=s;
                    return;
                }
    	   	case 2:
            	{
                 	b=(praw*Form1->Dane.n)/100;
                	for (int a=0;a<(Form1->Dane.n);a++)
                 		{
							praw=(b*100)/(Form1->Dane.n-a);
                     		if (praw>=random(300))
                        		{
                                    for (int c=0;c<b;c++)
                                      {
	                                	Form1->Dane.s[a]=!(Form1->Dane.s[a]);
                                        a++;
                                        x=c+1;
                                      }
                                    sprintf(s,"Wprowadzono b³êdów seryjnych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
			                		Form1->Label11->Caption=s;
                                    Form1->Label40->Caption=s;
               	                    return;
                		       	}
                    	}
                    sprintf(s,"Wprowadzono b³êdów seryjnych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
                    Form1->Label11->Caption=s;
                    Form1->Label40->Caption=s;
                    return;
				}
	       	case 3:
            	{
                    b=(praw*Form1->Dane.n)/100;
                	for (int a=0;a<(Form1->Dane.n);a++)
                 		{
                          	praw=(b*100)/(Form1->Dane.n-a);
                     		if (praw>=random(150))
                        		{
                                	Form1->Dane.s[a]=!(Form1->Dane.s[a]);
									x++;
	                                if (x>=b)
                                    	{
        	                        		sprintf(s,"Wprowadzono b³êdów losowych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
					                		Form1->Label11->Caption=s;
                                            Form1->Label40->Caption=s;
                                            return;
                                        }
                		       	}
                    	}
                    sprintf(s,"Wprowadzono b³êdów losowych : %i, czyli %i%%",x,(x*100/(Form1->Dane.n)));
                    Form1->Label11->Caption=s;
                    Form1->Label40->Caption=s;
                    return;
                }
	   	}
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Label12Click(TObject *Sender)
{
	CheckBox1->Checked=true;
    CheckBox2->Checked=false;
    CheckBox3->Checked=false;
    Dane.blad=1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Label15Click(TObject *Sender)
{
	CheckBox2->Checked=true;
    CheckBox1->Checked=false;
    CheckBox3->Checked=false;
    Dane.blad=2;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Label20Click(TObject *Sender)
{
	CheckBox3->Checked=true;
    CheckBox2->Checked=false;
    CheckBox1->Checked=false;
    Dane.blad=3;
}
//---------------------------------------------------------------------------
//                      << D E K O D O W A N I E >>
//---------------------------------------------------------------------------
void Dekodowanie(bool jak)
{
	int dmin=200,tmin=0,d=0,dminlast=0;
    Form1->Dane.nr=Form1->Dane.j;
	Form1->Dane.n0=4;
    Form1->Dane.k=7;
    GenerujTablice();
    for (int i=0;i<Form1->Dane.nr;i++)   //lecimy po bajtach
    	{
            for (int t=0;t<pow(2,Form1->Dane.il);t++)   //spr. wszystkie mozliwe stany
            	{
                    if ((d=Sprawdz(t,i))<dmin)  //d-odleg³oœæ dla t-stanu
                    	{	dmin=d;
                         	tmin=t;
                        }
                }
   // dla tmin mamy stan zdekodowany !!!
            dminlast+=dmin;
            Form1->Dane.sprwe[i]=Form1->Dane.tablica[tmin][0];
            if (jak==false)
            	{   Form1->Label21->Caption=IntToStr(dmin);
					Form1->Label22->Caption=IntToStr(tmin);
                    Form1->Label28->Caption=IntToStr(i);
                    Form1->Label30->Caption=IntToStr(Form1->Dane.nr-1);
                    ShowMessage("Nastêpny krok");
                }
            dmin=200;
        }
   	Wyswietl2(tmin);
	Form1->Label25->Caption=IntToStr(dminlast);
}
//*************---------------------------***********************
int Sprawdz(int t,int i)
{
 int d=0;
 for (int z=0;z<Form1->Dane.il;z++)
 	{
     	Form1->Dane.sprwe[i+z]=Form1->Dane.tablica[t][z];
    }
 Kodowanie(true);
 for (int b=0;b<Form1->Dane.il;b++)       //b-bajtow sprawdzamy
 	{
 		for (int a=i;a<(i+4);a++)     //a-ty bit w b-tym bajcie
    		{
       			if (Form1->Dane.sprwy[(i*4)+(a-i)]!=Form1->Dane.s[(i*4)+(a-i)])
                	{
        				d++;
                    }
   			}
        i++;
    }
 return(d);
}
//****************************
void Wyswietl2(int t)
{
 char str[150]={0};
 char s[1];
 for (int a=0;a<(Form1->Dane.j);a++)
    {
    	sprintf(s,"%x",Form1->Dane.sprwe[a]);
        StrCat(str,s);
    }
 Form1->Memo3->Text=str;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button3Click(TObject *Sender)
{
	Dekodowanie(true);
}
//---------------------------------------------------------------------------
//-------------+++++++++++++++++++++++++
void GenerujTablice()
{
	int t=0;
	for (int a=0;a<pow(2,Form1->Dane.il);a++)
    	{   t=a;
	        if ((t/2048)>=1)  { Form1->Dane.tablica[a][11]=1;	t=t-2048;	}
            else            Form1->Dane.tablica[a][11]=0;
        	if ((t/1024)>=1)  { Form1->Dane.tablica[a][10]=1;	t=t-1024;	}
            else            Form1->Dane.tablica[a][10]=0;
        	if ((t/512)>=1)  { Form1->Dane.tablica[a][9]=1;	t=t-512;	}
            else            Form1->Dane.tablica[a][9]=0;
        	if ((t/256)>=1)  { Form1->Dane.tablica[a][8]=1;	t=t-256;	}
            else            Form1->Dane.tablica[a][8]=0;
            if ((t/128)>=1)  { Form1->Dane.tablica[a][7]=1;	t=t-128;	}
            else            Form1->Dane.tablica[a][7]=0;
        	if ((t/64)>=1)  { Form1->Dane.tablica[a][6]=1;	t=t-64;	}
            else            Form1->Dane.tablica[a][6]=0;
 		  	if ((t/32)>=1)  { Form1->Dane.tablica[a][5]=1;	t=t-32;	}
            else            Form1->Dane.tablica[a][5]=0;
           	if ((t/16)>=1)  { Form1->Dane.tablica[a][4]=1;	t=t-16;	}
            else           	Form1->Dane.tablica[a][4]=0;
			if ((t/8)>=1)   { Form1->Dane.tablica[a][3]=1;	t=t-8;	}
            else	       	Form1->Dane.tablica[a][3]=0;
       		if ((t/4)>=1)   { Form1->Dane.tablica[a][2]=1;	t=t-4;	}
            else            Form1->Dane.tablica[a][2]=0;
       		if ((t/2)>=1)   { Form1->Dane.tablica[a][1]=1; t=t-2;  }
            else            Form1->Dane.tablica[a][1]=0;
       		if ((t/1)>=1)  	Form1->Dane.tablica[a][0]=1;
            else            Form1->Dane.tablica[a][0]=0;
        }
}
void __fastcall TForm1::Button6Click(TObject *Sender)
{
	Dekodowanie(false);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ComboBox1Click(TObject *Sender)
{
  Label32->Caption=IntToStr(ComboBox1->ItemIndex+1);
  Dane.il=ComboBox1->ItemIndex+1;
  Label34->Caption=IntToStr(pow(2,Dane.il));
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button7Click(TObject *Sender)
{
Kodowanie(false);
ZatwierdzBlady();
WyswietlPoBledach();
}
//---------------------------------------------------------------------------
