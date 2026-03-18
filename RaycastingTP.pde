// TP1 - Système de Raycasting
// Raycasting avec murs aléatoires et détection d'intersection

int NUM_WALLS = 8;
int NUM_RAYS = 10;
float PERC_REFLECTWALL = 0.5;



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
  boolean isReflective = false;

  // Bordures de la scène
  walls[0] = new Wall(0, 0, width, 0,false);
  walls[1] = new Wall(width, 0, width, height,false);
  walls[2] = new Wall(width, height, 0, height,false);
  walls[3] = new Wall(0, height, 0, 0,false);

  // Murs aléatoires
  for (int i = 4; i < walls.length; i++) {
    float x1 = random(50, width - 50);
    float y1 = random(50, height - 50);
    float x2 = x1 + random(-120, 120);
    float y2 = y1 + random(-120, 120);
    float chance = random(1);
    isReflective = (chance < PERC_REFLECTWALL);
    
    println("Mur n°" + i + " - Réfléchissant : " + isReflective);
    
    walls[i] = new Wall(x1, y1, x2, y2,isReflective);
  }
}

void castRays() {
  for (int i = 0; i < NUM_RAYS; i++) {
    float angle = map(i, 0, NUM_RAYS, 0, TWO_PI);
    PVector rayDir = new PVector(cos(angle), sin(angle));
    PVector rayOrigin = source.copy();

    int maxBounces = 10;
    
    for (int bounces = 0; bounces < maxBounces; bounces++) {
      Wall closestWall = null;
      PVector closestPoint = null;
      float minDist = Float.MAX_VALUE;

      Ray currentRay = new Ray(rayOrigin, rayDir);

      for (Wall w : walls) {
        PVector hit = currentRay.cast(w);
        if (hit != null) {
          float d = PVector.dist(rayOrigin, hit);
          if (d > 0.1 && d < minDist) {
            minDist = d;
            closestPoint = hit;
            closestWall = w;
          }
        }
      }

      if (closestPoint != null) {
        // --- GESTION DES COULEURS ET DE L'INTENSITÉ ---
        if (bounces == 0) {
          // Rayon de base : Bleu d'origine
          float dTotal = dist(0, 0, width, height);
          float alphaBase = map(minDist, 0, dTotal, 180, 30);
          stroke(100, 200, 255, alphaBase);
          strokeWeight(3);
        } else {
          // Rebonds : Jaune qui s'éteint très vite (Lumière réduite davantage)
          // La luminosité tombe de 180 à 20 (très sombre sur la fin)
          float shine = map(bounces, 1, maxBounces, 180, 20);
          float sw = max(3.0 - (bounces * 0.8), 0.5);
          float alphaRebond = map(bounces, 1, maxBounces, 120, 10);
          
          stroke(shine, shine, 0, alphaRebond); 
          strokeWeight(sw);
        }

        line(rayOrigin.x, rayOrigin.y, closestPoint.x, closestPoint.y);

        if (closestWall.isReflective) {
          // Calcul de la normale et de la réflexion
          float dx = closestWall.b.x - closestWall.a.x;
          float dy = closestWall.b.y - closestWall.a.y;
          PVector normal = new PVector(-dy, dx).normalize();

          float dot = rayDir.dot(normal);
          rayDir = PVector.sub(rayDir, PVector.mult(normal, 2 * dot));
          rayOrigin = closestPoint.copy();
        } else {
          // Impact final (point discret)
          if (bounces == 0) fill(255, 100, 100); // Rouge si premier impact
          else fill(150, 150, 0, 50); // Jaune sombre sinon
          noStroke();
          ellipse(closestPoint.x, closestPoint.y, 2, 2);
          break; 
        }
      } else {
        break; 
      }
    }
  }
}


// Regenère les murs avec la touche R
void keyPressed() {
  if (key == 'r' || key == 'R') {
    generateWalls();
  }
}
