// TP1 - Système de Raycasting avec ennemis
// Les rayons détectent et éliminent les ennemis

import java.util.ArrayList;

int NUM_WALLS = 8;
int NUM_RAYS = 10;
float PERC_REFLECTWALL = 0.5;
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
  boolean isReflective = false;

  // Bordures de la scène
  walls[0] = new Wall(0, 0, width, 0,false);
  walls[1] = new Wall(width, 0, width, height,false);
  walls[2] = new Wall(width, height, 0, height,false);
  walls[3] = new Wall(0, height, 0, 0,false);

  for (int i = 4; i < walls.length; i++) {
    float x1 = random(80, width - 80);
    float y1 = random(80, height - 80);
    float x2 = x1 + random(-140, 140);
    float y2 = y1 + random(-140, 140);
    
    float chance = random(1);
    isReflective = (chance < PERC_REFLECTWALL);
    walls[i] = new Wall(x1, y1, x2, y2,isReflective);
    
    println("Mur n°" + i + " - Réfléchissant : " + isReflective);
    
    walls[i] = new Wall(x1, y1, x2, y2,isReflective);
  }
}

void castRays() {
  for (int i = 0; i < NUM_RAYS; i++) {
    float angle = map(i, 0, NUM_RAYS, 0, TWO_PI);
    PVector rayDir = new PVector(cos(angle), sin(angle));
    PVector rayOrigin = source.copy(); // Assure-toi que 'source' est défini globalement

    int maxBounces = 10;
    
    for (int bounces = 0; bounces < maxBounces; bounces++) {
      Wall closestWall = null;
      PVector closestPoint = null;
      float minDist = Float.MAX_VALUE;

      // Utilisation du bon nom de classe (Rayon ou Ray selon ton projet)
      Rayon currentRay = new Rayon(rayOrigin, rayDir);

      // 1. Chercher le mur le plus proche
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

      // 2. Chercher un ennemi plus proche que le mur
      Ennemi ennemiTouche = null;
      float minEnnemiDist = minDist; // On ne regarde pas plus loin que le mur

      for (Ennemi e : ennemis) {
        PVector hit = currentRay.castEnnemi(e); // Vérifie que castEnnemi existe dans Rayon
        if (hit != null) {
          float d = PVector.dist(rayOrigin, hit);
          if (d < minEnnemiDist) {
            minEnnemiDist = d;
            ennemiTouche = e;
          }
        }
      }

      // 3. Si on touche un ennemi (prioritaire sur le mur)
      if (ennemiTouche != null) {
        ennemiTouche.touche = true;
        // Optionnel : dessiner le segment jusqu'à l'ennemi
        stroke(255, 0, 0); // Rouge pour les ennemis
        line(rayOrigin.x, rayOrigin.y, rayOrigin.x + rayDir.x * minEnnemiDist, rayOrigin.y + rayDir.y * minEnnemiDist);
        break; // Le rayon s'arrête net sur l'ennemi
      }

      // 4. Si on touche un mur
      if (closestPoint != null) {
        // --- STYLE DU RAYON ---
        if (bounces == 0) {
          float dTotal = dist(0, 0, width, height);
          float alphaBase = map(minDist, 0, dTotal, 180, 30);
          stroke(100, 200, 255, alphaBase); // Bleu
          strokeWeight(3);
        } else {
          float shine = map(bounces, 1, maxBounces, 180, 20);
          float sw = max(3.0 - (bounces * 0.8), 0.5); // Ta formule de réduction rapide
          float alphaRebond = map(bounces, 1, maxBounces, 120, 10);
          stroke(shine, shine, 0, alphaRebond); // Jaune
          strokeWeight(sw);
        }

        line(rayOrigin.x, rayOrigin.y, closestPoint.x, closestPoint.y);

        // 5. GESTION DU REBOND OU ARRÊT
        if (closestWall.isReflective) {
          float dx = closestWall.b.x - closestWall.a.x;
          float dy = closestWall.b.y - closestWall.a.y;
          PVector normal = new PVector(-dy, dx).normalize();
          float dot = rayDir.dot(normal);
          
          rayDir = PVector.sub(rayDir, PVector.mult(normal, 2 * dot));
          rayOrigin = closestPoint.copy();
        } else {
          // Impact final sur mur non-réfléchissant
          noStroke();
          fill(bounces == 0 ? color(255, 100, 100) : color(150, 150, 0, 50));
          ellipse(closestPoint.x, closestPoint.y, 2, 2);
          break; 
        }
      } else {
        break; 
      }
    }
  }

  // Nettoyage des ennemis morts
  for (int i = ennemis.size() - 1; i >= 0; i--) {
    if (ennemis.get(i).touche) {
      ennemis.remove(i);
    }
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
