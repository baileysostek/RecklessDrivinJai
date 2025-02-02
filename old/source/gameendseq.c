#include "gameframe.h"
#include "lzrwHandleInterface.h"
#include "error.h"
#include "screen.h"
#include "input.h"
#include "gamesounds.h"

#define kScrollSpeed	35	//pixels per second

int KeyPress()
{
	int pressed=false;
	KeyMap theKeys;
	GetKeys(theKeys);
	pressed=theKeys[0]|theKeys[1]|theKeys[2]|theKeys[3]|Button();
	return pressed;
}

void GameEndSequence()
{
	int yScroll;
	Pattern black;
	GWorldPtr textGW;
	GWorldPtr screenGW=GetScreenGW(); 
	GWorldPtr oldGW;
	GDHandle oldGD;
	UInt64 startMS;
	PicHandle pic=(PicHandle)GetResource('PPic',1009);
	Rect picSize,draw;
	PauseFrameCount();
	BeQuiet();
	FadeScreen(1);
 	LZRWDecodeHandle(&pic);
 	GetQDGlobalsBlack(&black);
 	picSize=(**pic).picFrame;
	GetGWorld(&oldGW,&oldGD);
	DoError(NewGWorld(&textGW,8,&picSize,nil,nil,0));
	SetGWorld(textGW,nil);
	FillRect(&picSize,&black);
	DrawPicture((PicHandle)pic,&picSize);
	DisposeHandle(pic);		
	SetGWorld(screenGW,nil);
	SetRect(&draw,0,0,640,480);
	FillRect(&draw,&black);
	FadeScreen(512);
	startMS=GetMSTime();
	for(yScroll=0;yScroll<(picSize.bottom-picSize.top)+480&&!KeyPress();yScroll+=1)
	{
		float time=(GetMSTime()-startMS)/(float)1000000;
		if(yScroll>=time*kScrollSpeed)
		{
			SetRect(&draw,320-(picSize.right-picSize.left)/2,480-yScroll,320+(picSize.right-picSize.left)/2,480+(picSize.bottom-picSize.top)-yScroll);
			CopyBits(GetPortBitMapForCopyBits(textGW),GetPortBitMapForCopyBits(screenGW),&picSize,&draw,srcCopy,nil);	
			while(yScroll>=time*kScrollSpeed)time=(GetMSTime()-startMS)/(float)1000000;
		}
	}
	SetRect(&draw,0,0,640,480);
	FillRect(&draw,&black);
	SetGWorld(oldGW,oldGD);
	DisposeGWorld(textGW);
	FadeScreen(1);
	FadeScreen(512);
	FlushInput();
	ResumeFrameCount();
}