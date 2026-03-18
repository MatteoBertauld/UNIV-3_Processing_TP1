// Classe Wall - représente un segment de mur

class Wall {
  PVector a, b; // Points de début et de fin
  boolean isReflective;

  Wall(float x1, float y1, float x2, float y2, boolean reflective) {
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
    this.isReflective = reflective;
  }

  void show() {
    
    if (isReflective) {
      stroke(0, 255, 200); // Vert/Bleu pour le miroir
    } else {
      stroke(255, 50, 50);  // Rouge pour le mur bloquant
    }
    
    //stroke(180, 100, 255);
    strokeWeight(2.5);
    line(a.x, a.y, b.x, b.y);

    // Points aux extrémités
    fill(220, 150, 255);
    noStroke();
    ellipse(a.x, a.y, 6, 6);
    ellipse(b.x, b.y, 6, 6);
  }
}
