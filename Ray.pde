// Classe Ray - représente un rayon

class Ray {
  PVector origin;
  PVector dir;

  Ray(PVector origin, PVector dir) {
    this.origin = origin.copy();
    this.dir = dir.copy();
  }

  // Calcule l'intersection du rayon avec un mur (algorithme segment-segment)
  // Retourne le point d'intersection ou null s'il n'y en a pas
  PVector cast(Wall wall) {
    float x1 = wall.a.x;
    float y1 = wall.a.y;
    float x2 = wall.b.x;
    float y2 = wall.b.y;

    float x3 = origin.x;
    float y3 = origin.y;
    float x4 = origin.x + dir.x;
    float y4 = origin.y + dir.y;

    float denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

    // Rayon parallèle au mur
    if (denom == 0) return null;

    float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;

    // Intersection valide : t entre 0 et 1 (sur le mur), u > 0 (dans la direction du rayon)
    if (t > 0 && t < 1 && u > 0) {
      float px = x1 + t * (x2 - x1);
      float py = y1 + t * (y2 - y1);
      return new PVector(px, py);
    }

    return null;
  }
}
