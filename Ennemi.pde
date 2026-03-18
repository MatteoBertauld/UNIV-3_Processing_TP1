// Classe Ennemi - se déplace aléatoirement, éliminé si touché par un rayon

class Ennemi {
  PVector pos;
  PVector vel;
  float radius = 12;
  boolean touche = false;
  float flashTimer = 0;

  Ennemi(float x, float y) {
    pos = new PVector(x, y);
    float angle = random(TWO_PI);
    float speed = random(0.8, 2.2);
    vel = new PVector(cos(angle) * speed, sin(angle) * speed);
  }

  void update() {
    pos.add(vel);
    // Rebondir sur les murs
for (Wall w : walls) {
  // Vecteur du mur
  PVector ab = PVector.sub(w.b, w.a);
  PVector ap = PVector.sub(pos, w.a);
  float t = constrain(PVector.dot(ap, ab) / ab.magSq(), 0, 1);
  PVector closest = PVector.add(w.a, PVector.mult(ab, t));
  float d = PVector.dist(pos, closest);

  if (d < radius) {
    // Normale du mur
    PVector normal = new PVector(-ab.y, ab.x).normalize();
    // S'assurer que la normale pointe vers l'ennemi
    if (PVector.dot(normal, PVector.sub(pos, closest)) < 0) normal.mult(-1);
    // Réfléchir la vitesse
    float dot = PVector.dot(vel, normal);
    vel.sub(PVector.mult(normal, 2 * dot));
    // Repousser l'ennemi hors du mur
    pos.add(PVector.mult(normal, radius - d + 1));
  }
}

    // Changer de direction aléatoirement de temps en temps
    if (random(1) < 0.01) {
      float angle = random(TWO_PI);
      float speed = random(0.8, 2.2);
      vel = new PVector(cos(angle) * speed, sin(angle) * speed);
    }
  }

  void show() {
    // Corps de l'ennemi
    noStroke();
    fill(255, 60, 60);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
  }
}
