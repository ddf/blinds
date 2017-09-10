//  Copyright © 2017 Damien Quartz.

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

float[] lineX;
float[] lineF;
float[] lineO;
// these are expressed as a percentage of the pixel-width of the screen
// based on fixed pixel values arrived at through experimentation on a 1280x800 screen
float   minSpacing = 0.01171875f;
float   maxSpacing = 0.0234375f;
float   wiggle     = 0.00234375;
float   ratio      = 1;

boolean WITH_AUDIO = true;
Minim minim;
AudioOutput out;
Oscil[] osc;
Line[] phase;
Line[] amp;
boolean muted = false;

boolean exportGif = false;

void setup()
{
  //size(315,250);
  fullScreen();
  background(0);
  noCursor();
  if ( exportGif )
  {
    frameRate(30);
    minSpacing *= 2;
    maxSpacing *= 2;
    wiggle *= 2;
    ratio = 0.5f*(1280.0f/width);
  }
  else
  {
    frameRate(60);
    ratio = (1280.0f/width);
  }
  
  int count = int(1.0f / minSpacing);
  lineX = new float[count];
  lineF = new float[count];
  lineO = new float[count];
  
  if ( WITH_AUDIO )
  {
    minim = new Minim(this);
    out = minim.getLineOut();
    osc = new Oscil[count];
    phase = new Line[count];
    amp   = new Line[count];
  }
  
  Wavetable wave = WavetableGenerator.gen10(4096, new float[] { 1 });
  
  float px = 0;
  for(int i = 0; i < count; ++i)
  {
    lineX[i] = px + random(width*minSpacing, width*maxSpacing);
    px = lineX[i];
    lineF[i] = random(2f, 8f);
    
    int note = (i)+32;
    if ( WITH_AUDIO && i%2==0 && note < 128 )
    {
      osc[i] = new Oscil(Frequency.ofMidiNote(note), 0, wave );
      phase[i] = new Line(0,0,0);
      phase[i].patch( osc[i].phase );
      amp[i] = new Line(0,0,0);
      amp[i].patch( osc[i].amplitude );
      float pw = 0.7f;
      float p = px < width/2 ? map(px, 0, width/2, 0, -pw) : map(px, width/2, width, -pw, pw);
      Pan pan = new Pan(p);
      osc[i].patch( pan ).patch(out);
    }
  }
}

void draw()
{
  background(0);
  rectMode(CORNER);
  strokeWeight(width*wiggle);
  float ptx = 0;
  float pbx = 0;
  float dt = exportGif ? 1.0f / 30.0f : 1.0f / frameRate;
  for(int i = 0; i < lineX.length; ++i)
  {
    float ctx = lineX[i];
    if ( ctx >= width ) break;
    float cbx = lineX[i]+sin(lineO[i])*width*wiggle;
    // scale the distance based on ratio between our test width and the actual width.
    // this should give us about the same range of grey values regardless of resolution.
    float d = (cbx - pbx)*ratio;
    noStroke();
    float h = d*d*0.08f; 
    fill(h);
    quad(ptx, 0, ctx, 0, cbx, height, pbx, height);
    stroke(225);
    line(ctx, 0, cbx, height);
    ptx = ctx;
    pbx = cbx;
    float fmod = sin((frameCount+i)*0.14);
    lineO[i] += (lineF[i]+fmod)*dt;
    
    if ( !muted && WITH_AUDIO && osc[i] != null )
    {
      float v = constrain((h)/255.0f, 0, 1);
      float s = map(ctx, 0, width, 1.1f, 0.2f);
      float a = v*v*s*1.4;
      amp[i].activate(dt, osc[i].amplitude.getLastValue(), a);
      phase[i].activate(dt, osc[i].phase.getLastValue(), 0.5f*sin(lineO[i]));
    }
  }
  
  float d = (width - pbx)*ratio;
  noStroke();
  fill(d*d*0.08f);
  quad(ptx, 0, width, 0, width, height, pbx, height); 
  
  if (exportGif)
  {
    saveFrame("gif/frame-####.tif");
    if ( frameCount > 150 )
    {
      exit();
    }
  }
}

void keyPressed()
{
  if ( key == 'm' || key == 'M' )
  {
    muted = !muted;
    if ( muted )
    {
      for(int i = 0; i < amp.length; ++i)
      {
        if ( osc[i] != null )
        {
          amp[i].activate(0.025f, osc[i].amplitude.getLastValue(), 0);
        }
      }
    }
  }
}