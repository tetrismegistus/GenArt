import toxi.audio.*;
import toxi.color.*;
import toxi.color.theory.*;
import toxi.data.csv.*;
import toxi.data.feeds.*;
import toxi.data.feeds.util.*;
import toxi.doap.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.geom.mesh.subdiv.*;
import toxi.geom.mesh2d.*;
import toxi.geom.nurbs.*;
import toxi.image.util.*;
import toxi.math.*;
import toxi.math.conversion.*;
import toxi.math.noise.*;
import toxi.math.waves.*;
import toxi.music.*;
import toxi.music.scale.*;
import toxi.net.*;
import toxi.newmesh.*;
import toxi.nio.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.constraints.*;
import toxi.physics3d.*;
import toxi.physics3d.behaviors.*;
import toxi.physics3d.constraints.*;
import toxi.processing.*;
import toxi.sim.automata.*;
import toxi.sim.dla.*;
import toxi.sim.erosion.*;
import toxi.sim.fluids.*;
import toxi.sim.grayscott.*;
import toxi.util.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.volume.*;

ToxiclibsSupport gfx;
Voronoi voronoi;


ArrayList<PVector> points = new ArrayList<PVector>();
float x = .1;
float y = 0.0;
float z = 0.0;

float sigma = random(1, 100);
float rho = random(1, 300); 
float beta = random(20, 50)/random(1, 19);

float hue = 0;

void setup()
{
    size(800, 800);
    colorMode(HSB, 360, 100, 100, 1);
    gfx = new ToxiclibsSupport( this );
    voronoi = new Voronoi();
    voronoi.addPoint(new Vec2D(z, y));
    stroke(255);
    noFill();

}

void draw() {
  background(0);
  translate(width/5, height/2);
  float dt = 0.001;
  float dx = (sigma * (y - x)) * dt;
  float dy = (x * (rho - z) - y) * dt;
  float dz = (x * y - beta * z) * dt;
  x += dx;
  y += dy;
  z += dz;
  voronoi.addPoint(new Vec2D(z, y));
  

  for ( Polygon2D polygon : voronoi.getRegions() ) {
      
      gfx.polygon2D( polygon );
      
      
  }

}


void keyPressed() {
  if (key == 's') {
    save("test.png");
  } 
}
