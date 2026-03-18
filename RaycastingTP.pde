// TP1 - Système de Raycasting avec ennemis
// Les rayons détectent et éliminent les ennemis

import java.util.ArrayList;

int NUM_WALLS = 8;
int NUM_RAYS = 10;
int SPAWN_INTERVAL = 1;

Wall[] walls;
PVector source;
ArrayList<Ennemi> ennemis;
int lastSpawn = 0;

void setup() {
  size(800, 600);
  source = new PVector(width / 2, height / 2);
  generateWalls();
  ennemis = new ArrayList<Ennemi>();
  for (int i = 0; i < 5; i++) {
    spawnEnnemi();
  }
}

void draw() {
  background(15, 15, 30);

  source.set(mouseX, mouseY);

  if (millis() - lastSpawn > SPAWN_INTERVAL * 1000) {
    spawnEnnemi();
    lastSpawn = millis();
  }

  for (Ennemi e : ennemis) {
    e.update();
    e.show();
  }

  // Dessiner les murs
  for (Wall w : walls) {
    w.show();
  }

  // Lancer les rayons
  castRays();

  // Dessiner la source
  fill(255, 220, 50);
  noStroke();
  ellipse(source.x, source.y, 14, 14);
  noFill();
  stroke(255, 220, 50, 60);
  strokeWeight(1);
  ellipse(source.x, source.y, 30, 30);

  // Infos
  fill(255);
  noStroke();
  textSize(14);
  text("R = nouveaux murs", 15, height - 15);
}

void spawnEnnemi() {
  // Spawn sur un bord aléatoire
  float x, y;
  int bord = int(random(4));
  if (bord == 0)      { x = random(width); y = 0; }
  else if (bord == 1) { x = width;         y = random(height); }
  else if (bord == 2) { x = random(width); y = height; }
  else                { x = 0;             y = random(height); }
  ennemis.add(new Ennemi(x, y));
}

void generateWalls() {
  walls = new Wall[NUM_WALLS + 4];
  walls[0] = new Wall(0, 0, width, 0);
  walls[1] = new Wall(width, 0, width, height);
  walls[2] = new Wall(width, height, 0, height);
  walls[3] = new Wall(0, height, 0, 0);

  for (int i = 4; i < walls.length; i++) {
    float x1 = random(80, width - 80);
    float y1 = random(80, height - 80);
    float x2 = x1 + random(-140, 140);
    float y2 = y1 + random(-140, 140);
    walls[i] = new Wall(x1, y1, x2, y2);
  }
}

void castRays() {
  for (int i = 0; i < NUM_RAYS; i++) {
    float angle = map(i, 0, NUM_RAYS, 0, TWO_PI);
    PVector dir = new PVector(cos(angle), sin(angle));
    Rayon ray = new Rayon(source, dir);

    // Mur le plus proche
    PVector closestWall = null;
    float minWallDist = Float.MAX_VALUE;
    for (Wall w : walls) {
      PVector hit = ray.cast(w);
      if (hit != null) {
        float d = PVector.dist(source, hit);
        if (d < minWallDist) {
          minWallDist = d;
          closestWall = hit;
        }
      }
    }

    // Ennemi le plus proche devant le mur
    Ennemi ennemiTouche = null;
    float minEnnemiDist = minWallDist;
    for (Ennemi e : ennemis) {
      PVector hit = ray.castEnnemi(e);
      if (hit != null) {
        float d = PVector.dist(source, hit);
        if (d < minEnnemiDist) {
          minEnnemiDist = d;
          ennemiTouche = e;
        }
      }
    }

    // Dessiner le rayon
    if (ennemiTouche != null) {
      stroke(255, 80, 80, 150);
      strokeWeight(0.8);
      line(source.x, source.y, ennemiTouche.pos.x, ennemiTouche.pos.y);
      ennemiTouche.touche = true;
    } else if (closestWall != null) {
      float alpha = map(minWallDist, 0, dist(0, 0, width, height), 180, 30);
      stroke(100, 200, 255, alpha);
      strokeWeight(0.8);
      line(source.x, source.y, closestWall.x, closestWall.y);
    }
  }

  // Éliminer les ennemis touchés
  for (int i = ennemis.size() - 1; i >= 0; i--) {
    if (ennemis.get(i).touche) ennemis.remove(i);
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    generateWalls();
    ennemis.clear();
    for (int i = 0; i < 4; i++) spawnEnnemi();
    lastSpawn = millis();
  }
}
