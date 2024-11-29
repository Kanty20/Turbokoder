#include<stdio.h>
#include<conio.h>
#include<stdlib.h>

void tytul(void);
void koder(void);
void kanal(void);
char dekoder(void);

int dl;
int nn2[100];
char nn[100];
int bledy[100];
int kod[100][3];
int tab[100][3];

int main() {
	int c=0;
	tytul();
	clrscr();

	printf("Symulacja kodera.\n\n");
	koder();
skok:
	printf("\n\nSymulacja kanalu ziarnistego.\n");
	kanal();
	printf("\nSymulacja dekodera.\n");
	c=dekoder();
	if(c==1)
		goto skok;

}

void koder(void) {
	char ch;
	int i,j;
	int rwe[]={0, 0, 0, 0, 0, 0, 0, 0};

	printf("Podaj dˆugosc ci¥gu informacyjnego: ");
	scanf("%ld",&dl);
	printf("\nWprowad« ci¥g informacyjny: ");
		for (i=0; i<dl;) {
		ch=getch();
		if (ch==48||ch==49) {
			nn[i]=ch-48;
			putch(ch);
			i++;
		}
	}
	printf("\n\nCi¥g kodowy: \n");
	for(j=0;j<dl+7;j++){
		for(i=7;i>0;i--)
			rwe[i]=rwe[i-1];
		if(j<dl) {
			nn2[j]=*(nn+j);
			rwe[0]=*(nn+j); }
		else
			rwe[0]=0;

		kod[j][0]=(rwe[0]+rwe[2]+rwe[4]+rwe[7])%2;
		kod[j][1]=(rwe[0]+rwe[3]+rwe[4]+rwe[6]+rwe[7])%2;
		kod[j][2]=(rwe[0]+rwe[1]+rwe[2]+rwe[4]+rwe[5]+rwe[6]+rwe[7])%2;
		printf("%d%d%d ",kod[j][0],kod[j][1],kod[j][2]);
		if((j+1)%20==0)
			printf("\n");
		}
	for(i=0;i<dl+7;i++)
		for(j=0;j<3;j++)
			tab[i][j]=kod[i][j];
}

void kanal(void) {
	double prw,prws;
	int i,j,c,x,y,n=0;
	char t[100];

jeszczeraz:
	randomize();
	clrscr();
	printf("Symulacja kanaˆu.\n");
	printf("(1) - Wprowadzanie mi©kkie.\n(2) - Wprowadzanie twarde.\n");
	do 
		c=getch();
	while (c!='1'&&c!='2');
	if (c=='2') {
		printf("\t(1) - Bˆ©dy pojedyncze.\n\t(2) - Bˆ©dy seryjne.");
		do
			c=getch();
		while (c!='1'&&c!='2');
		if (c=='2') {
			for(i=0;i<dl+7;i++)
				for(j=0;j<3;j++)
					kod[i][j]=tab[i][j];
			for(i=0;i<100;i++)
				bledy[i]=0;
			printf("\n\nPodaj prawdopodobieästwo wyst¥pienia przekˆamania dla bˆ©du seryjnego (0..1): ");
			scanf("%lg",&prws);
			printf("\n");
			x=prws*(dl+7)*3;
			printf("Wystapiˆ %d bitowy bˆ¥d seryjny.\n",x);
			n=random(3*(dl+7)-x);	/*n-poczatek wystapienia bledu seryjnego*/
			i=n/3;
			j=n%3;
			for (c=0; c<x; c++){
				bledy[n++]=1;
            kod[i][j++]=!kod[i][j];
				if((j%3)==0){
					j=0;
					i++;
				}
			}
			goto dalej;
		}
		if (c=='1') {
			for(i=0;i<100;i++)
				t[i]=0;
			printf("\nWprowad« wektor bˆ©d¢w (max. dˆugo˜† %d bit¢w): ",(dl+7)*3);
			scanf("%s",t);
			x=0;
			for(i=0;i<(3*(dl+7));i++){
				t[i]=t[i]-48;
				if(t[i]==1){
					x++;
					j=i/3;
					y=i%3;
					if(kod[j][y]==0)
						kod[j][y]=1;
					else
						kod[j][y]=0;
					}
				}
			goto jump1;
		}
	}
	if (c=='1') {
		int p;
		x=0;
		printf("\nPodaj prawdopodobieästwo wyst¥pienia bˆ©d¢w w kanale ziarnistym [%]: ");
		scanf("%d",&p);
		for(i=0;i<dl+7;i++) {
			for(j=0;j<3;j++) {
				if (random(100)<p) {
					x++;
					kod[i][j]=!kod[i][j];
				}
			}
		}
	}
jump1:	printf("\nWyst¥piˆy %d bˆ©dy.\n",x);
dalej:	printf("Ci¥g kodowy na wyj˜ciu kanaˆu:\n");
	for(j=0;j<dl+7;j++){
		printf("%d%d%d ",kod[j][0],kod[j][1],kod[j][2]);
		if((j+1)%20==0)
			printf("\n");
		}
	printf("\n");
	for(j=0,y=0;j<dl+7;j++){
		for(i=0;i<3;i++){
			if(bledy[y]==1)
				printf("B");
			else
				printf(" ");
			y++;
			}
		printf(" ");
		}
						 /*
	printf("\nCzy chcesz jeszcze raz poda† dany ci¥g kodowy na wej˜cie kanaˆu [t/n]:");
	getchar();
	c=getchar();
	if(c==116)
		goto jeszczeraz;*/
}
char dekoder(void)
{
	struct k{
		int w[8];
		int waga;
		int ww[8];
		int waga2;
		}stany[128];
	struct k1{
		int bit;
		int minwaga;
		}mw;
	int d[3],wyj[100];
	int i,j,x,y,c,bit,m,mm,max=1;

for(i=0;i<128;i++){		/*zerowanie*/
	stany[i].waga=0;
	for(j=0;j<8;j++)
		stany[i].w[j]=0;
	}

for(i=0;i<7;i++){
	max=2*max;
	bit=0;
	mm=128/max;
	for(j=0;j<max;j++){
		m=(128/max)*j;

		for(x=m;x<mm;x++){
			for(y=7;y>0;y--)
				stany[x].w[y]=stany[x].w[y-1];
			stany[x].w[0]=bit;
			}
		d[0]=(stany[m].w[0]+stany[m].w[2]+stany[m].w[4]+stany[m].w[7])%2;
		d[1]=(stany[m].w[0]+stany[m].w[3]+stany[m].w[4]+stany[m].w[6]+stany[m].w[7])%2;
		d[2]=(stany[m].w[0]+stany[m].w[1]+stany[m].w[2]+stany[m].w[4]+stany[m].w[5]+stany[m].w[6]+stany[m].w[7])%2;

		for(x=0;x<3;x++)
			if(kod[i][x]!=d[x])
				for(y=m;y<mm;y++)
					stany[y].waga++;

		mm=mm+128/max;
		if(bit==0)
			bit=1;
		else
			bit=0;
		}
	}
printf("Ciag informacyjny na wyjsciu dekodera:\n");
for(i=0;i<dl;i++){
	mw.minwaga=150;
	for(j=0;j<128;j++){				/*przepisanie z w do ww*/
		stany[j].waga2=stany[j].waga;
		for(x=0;x<8;x++)
			stany[j].ww[x]=stany[j].w[x];
		}

	bit=0;
	x=0;
	for(j=0;j<64;j++){
		for(y=7;y>0;y--)
			stany[j].ww[y]=stany[j].ww[y-1];	/*przesuw*/

		c=2;
		while(c--){
			for(y=1;y<8;y++)
				stany[x].w[y]=stany[j].ww[y];	/*pzepisanie*/
			stany[x].w[0]=bit;
			stany[x].waga=stany[j].waga2;
			d[0]=(stany[x].w[0]+stany[x].w[2]+stany[x].w[4]+stany[x].w[7])%2;
			d[1]=(stany[x].w[0]+stany[x].w[3]+stany[x].w[4]+stany[x].w[6]+stany[x].w[7])%2;
			d[2]=(stany[x].w[0]+stany[x].w[1]+stany[x].w[2]+stany[x].w[4]+stany[x].w[5]+stany[x].w[6]+stany[x].w[7])%2;

			for(y=0;y<3;y++)
				if(d[y]!=kod[i+7][y])
					stany[x].waga++;

			if(bit==0)
				bit=1;
			else
				bit=0;
			x++;
			}
		}

	bit=0;
	x=0;
	for(j=64;j<128;j++){
		for(y=7;y>0;y--)
			stany[j].ww[y]=stany[j].ww[y-1];

		c=2;
		while(c--){
			for(y=1;y<8;y++)
				stany[x].ww[y]=stany[j].ww[y];
			stany[x].ww[0]=bit;
			stany[x].waga2=stany[j].waga2;
			d[0]=(stany[x].ww[0]+stany[x].ww[2]+stany[x].ww[4]+stany[x].ww[7])%2;
			d[1]=(stany[x].ww[0]+stany[x].ww[3]+stany[x].ww[4]+stany[x].ww[6]+stany[x].ww[7])%2;
			d[2]=(stany[x].ww[0]+stany[x].ww[1]+stany[x].ww[2]+stany[x].ww[4]+stany[x].ww[5]+stany[x].ww[6]+stany[x].ww[7])%2;

			for(y=0;y<3;y++)
				if(d[y]!=kod[i+7][y])
					stany[x].waga2++;

			if(bit==0)
				bit=1;
			else
				bit=0;

			if(stany[x].waga2<stany[x].waga){
				stany[x].waga=stany[x].waga2;
				for(y=0;y<8;y++)
					stany[x].w[y]=stany[x].ww[y];
				}
			if(stany[x].waga<mw.minwaga){
				mw.minwaga=stany[x].waga;
				mw.bit=stany[x].w[7];
				}
			x++;
			}
		}


	wyj[i]=mw.bit;
	printf("%d   dl Ham:%d\t",wyj[i],mw.minwaga);
	if((i+1)%5==0)
		printf("\n");
	}

printf("\n\nZestawienie wynikow:\nCiag informacyjny: ");
for(i=0;i<dl;i++){
/*	nn2[i]=nn[i];*/
	printf("%d  ",nn2[i]);
	}
printf("\nCiag kodowy:\n");
for(i=0;i<3*(dl+7);){
	j=i/3;
	y=i%3;
	printf("%d",tab[j][y]);
	i++;
	if(i%3==0)
		printf(" ");
	}
printf("\nCiag kodowy po przejsciu przez kanal:\n");
for(i=0;i<3*(dl+7);){
	j=i/3;
	y=i%3;
	printf("%d",kod[j][y]);
	i++;
	if(i%3==0)
		printf(" ");
	}
printf("\n");
for(j=0,y=0;j<dl+7;j++){
	for(i=0;i<3;i++){
		if(bledy[y]==1)
			printf("B");
		else
			printf(" ");
		y++;
		}
	printf(" ");
	}
printf("\nCiag informacyjny na wyjsciu dekodera:\n\t\t   ");
for(i=0;i<dl;i++)
	printf("%d  ",wyj[i]);

printf("\n\nCzy chcesz jeszcze testowac uklad z tym samym wejsiowym ciagiem info. [t/n]:");
c=getch();
if(c=='T'||c=='t')
	return 1;
return 0;
}

void tytul(void) {
	clrscr();

	gotoxy(10,1);
	printf("INSTYTUT TELEKOMUNIKACJI I AKUSTYKI");
	printf(" POLITECHNIKI WROCAWSKIEJ");
	gotoxy(29,3);
	printf("KODOWANIE\t(PROJEKT)");
	gotoxy(17,10);
	printf("KOMPUTEROWA SYMULACJA PRACY KANAU KODOWEGO");
	gotoxy(16,11);
	printf("ZAWIERAJ¤CEGO KODER I DEKODER KODU SPLOTOWEGO");
	gotoxy(1,20);
	printf("Prowadz¥cy: dr in¾. Paweˆ Kabacik");
	gotoxy(3,21);
	printf("Wykonali: Piotr Borowiec, Paweˆ Pelc");
	getch();
}