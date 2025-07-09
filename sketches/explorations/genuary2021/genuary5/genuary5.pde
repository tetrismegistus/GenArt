size(800,800);colorMode(HSB);background(#B9BFFF);noStroke();float yo=0;for(int y=0;y<799;y+=3){float xo=0;for(int x=0;x<799;x+=3){float n=noise(xo,yo);fill(123,n*255,255);circle(x,y+100*n,15);xo+=0.1;}yo+=0.1;}
save("test.png");


  
  
