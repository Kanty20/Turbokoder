#include<stdio.h>
#include<conio.h>
#include<stdlib.h>

void koder(void);
void kanal(void);
char dekoder(void);
int dl;
int kod[100][3];
int tab[100][3];

void main()
{
	int c=0;

	clrscr();
	printf("Symulacja kodera.\n");
	koder();

skok:
	printf("\n\nSymulacja kanalu ziarnistego.\n");
	kanal();

	printf("\n\nSymulacja dekodera.\n");
	c=dekoder();
	if(c==1)
		goto skok;

}

void koder(void)
{
	int i,j;
	char nn[100];
	extern int dl;
	extern int kod[100][3];
	extern int tab[100][3];
	int rwe[]={0, 0, 0, 0, 0, 0, 0, 0};

	printf("Podaj dlugosc slowa wejsciowego:");
	scanf("%ld",&dl);
	printf("Wprowadz ciag wejsciowy kodera:");
	scanf("%s",nn);
	for(i=0;i<dl;i++)
		nn[i]=nn[i]-48;
	printf("\nCiag wyjsciowy kodera:\n");
	for(j=0;j<dl+7;j++){
		for(i=7;i>0;i--)
			rwe[i]=rwe[i-1];
		if(j<dl)
			rwe[0]=*(nn+j);
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
void kanal(void)
{
	double prw;
	int i,j,c,x,y,n=0;
	char t[100];
	extern int dl;
	extern int tab[100][3];
	extern int kod[100][3];

jeszczeraz:
	printf("Podaj prawdopodobienstwo wystapienia przeklamania na dowolnym bicie\n(dla bledow seryjnych podaj wartosc wieksza od 1,\n dla okresleni wektora bledow wpisz 0):");
	scanf("%lg",&prw);
	if(prw>1&&prw!=10){ 			/*obsluga bledu seryjnego*/
		for(i=0;i<dl+7;i++)
			for(j=0;j<3;j++)
				kod[i][j]=tab[i][j];

		printf("Podaj dlugosc bledu seryjnego:");
		scanf("%d",&x);
		printf("\n");
		n=random(3*(dl+7)-x);	/*n-poczatek wystapienia bledu seryjnego*/
		i=n/3;
		j=n%3;
		for(c=0;c<x;c++){
			if(kod[i][j]==0)
				kod[i][j++]=1;
			else
				kod[i][j++]=0;
			if((j%3)==0){
				j=0;
				i++;
				}
			}
		goto dalej;
		}
	for(i=0;i<dl+7;i++)
		for(j=0;j<3;j++)
			kod[i][j]=tab[i][j];

	if(prw==0){
		for(i=0;i<100;i++)
			t[i]=0;
		printf("Wprowadz wektor bledow:");
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
	prw=prw*3*(dl+7);
	for(x=0;x<prw;x++){
tak:		t[x]=random(3*(dl+7));
		for(i=0;i<x;i++)
			if(t[x]==t[i])
				goto tak;
		j=t[x]/3;
		i=t[x]%3;
		if(kod[j][i]==0)
			kod[j][i]=1;
		else
			kod[j][i]=0;
		}
jump1:	printf("\nWystapily %d bledy.\n",x);
dalej:	printf("Ciag kodowy na wyjsciu kanalu:\n");
	for(j=0;j<dl+7;j++){
		printf("%d%d%d ",kod[j][0],kod[j][1],kod[j][2]);
		if((j+1)%20==0)
			printf("\n");
		}

	printf("\nCzy chcesz jeszcze raz podac dany ciag kodowy na wejscie kanalu [t/n]:");
	getchar();
	c=getchar();
	if(c==116)
		goto jeszczeraz;
}
char dekoder(void)
{
	extern int kod[100][3];
	extern int dl;
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
printf("\n\nCzy chcesz jeszcze testowac uklad z tym samym wejsiowym ciagiem info. [t/n]:");
getchar();
c=getchar();
if(c==116)
	return 1;
return 0;
}








