// TP1 - Système de Raycasting
// Raycasting avec murs aléatoires et détection d'intersection

int NUM_WALLS = 8;
int NUM_RAYS = 360;
Wall[] walls;
PVector source;

void setup() {
  size(800, 600);
  source = new PVector(width / 2, height / 2);
  generateWalls();
}

void draw() {
  background(15, 15, 30);

  // Déplacer la source avec la souris
  source.set(mouseX, mouseY);

  // Dessiner les murs
  for (Wall w : walls) {
    w.show();
  }

  // Lancer les rayons
  castRays();

  // Dessiner la source
  fill(255, 220, 50);
  noStroke();
  ellipse(source.x, source.y, 12, 12);
}

// Génère des murs aléatoires
void generateWalls() {
  walls = new Wall[NUM_WALLS + 4];

  // Bordures de la scène
  walls[0] = new Wall(0, 0, width, 0);
  walls[1] = new Wall(width, 0, width, height);
  walls[2] = new Wall(width, height, 0, height);
  walls[3] = new Wall(0, height, 0, 0);

  // Murs aléatoires
  for (int i = 4; i < walls.length; i++) {
    float x1 = random(50, width - 50);
    float y1 = random(50, height - 50);
    float x2 = x1 + random(-120, 120);
    float y2 = y1 + random(-120, 120);
    walls[i] = new Wall(x1, y1, x2, y2);
  }
}

// Lance tous les rayons autour de la source
void castRays() {
  for (int i = 0; i < NUM_RAYS; i++) {
    float angle = map(i, 0, NUM_RAYS, 0, TWO_PI);
    PVector dir = new PVector(cos(angle), sin(angle));
    Ray ray = new Ray(source, dir);

    PVector closest = null;
    float minDist = Float.MAX_VALUE;

    for (Wall w : walls) {
      PVector hit = ray.cast(w);
      if (hit != null) {
        float d = PVector.dist(source, hit);
        if (d < minDist) {
          minDist = d;
          closest = hit;
        }
      }
    }

    if (closest != null) {
      // Couleur du rayon selon la distance (plus proche = plus brillant)
      float alpha = map(minDist, 0, dist(0, 0, width, height), 180, 30);
      stroke(100, 200, 255, alpha);
      strokeWeight(0.8);
      line(source.x, source.y, closest.x, closest.y);

      // Point d'impact
      fill(255, 100, 100);
      noStroke();
      ellipse(closest.x, closest.y, 4, 4);
    }
  }
}

// Regenère les murs avec la touche R
void keyPressed() {
  if (key == 'r' || key == 'R') {
    generateWalls();
  }
}
