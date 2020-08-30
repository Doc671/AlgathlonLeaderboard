class Athlete {
  public final String name;
  public final color colour;
  public final int startPoints;
  public final int earnedPoints;
  public final int newPoints;
  public int newPlace;

  public Athlete(String name, color colour, int startPoints, int earnedPoints) {
    this.name = name;
    this.colour = colour;
    this.startPoints = startPoints;
    this.earnedPoints = earnedPoints;
    this.newPoints = startPoints + earnedPoints;
  }
}
