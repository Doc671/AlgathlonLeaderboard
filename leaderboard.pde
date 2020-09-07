import java.util.Arrays;
import java.util.Comparator;

Athlete[] athletes;
int aliveAthletes, athletesToEliminate, barHeight, eliminatedTextDelay, eliminatedTextOffset, fontSize, marginTextAlign, maxScore, tick;
color backgroundColour, marginColour;
float progress;
boolean showTextOutlines;
PFont mainFont, eliminatedTextFont;

static String getOrdinalPostfix(int number) {
  if (number > 20) {
      number %= 10;
  }
  
  switch (number) {
    case 1: return "st";
    case 2: return "nd";
    case 3: return "rd";
    default: return "th";
  }
}

static float getLuminance(color colour) {
  // Colour is stored as a 32-bit ARGB integer
  // Use bitshifting and bitwise AND to extract the red, green and blue values
  int red = (colour & 0x00FF0000) >> 16;
  int green = (colour & 0x0000FF00) >> 8;
  int blue = colour & 0x000000FF;
  
  int max = max(red, green, blue);
  int min = min(red, green, blue);
  
  return float(max + min) / 2 / 255;
}

void parseJsonData() {
  JSONObject rootJsonObject = loadJSONObject("data.json");
  aliveAthletes = rootJsonObject.getInt("aliveAthletes");
  athletesToEliminate = rootJsonObject.getInt("athletesToEliminate");
  mainFont = loadFont(rootJsonObject.getString("mainFont"));
  eliminatedTextFont = loadFont(rootJsonObject.getString("eliminatedTextFont"));
  eliminatedTextDelay = int(rootJsonObject.getFloat("eliminatedTextDelay") * frameRate);
  showTextOutlines = rootJsonObject.getBoolean("showTextOutlines");
  
  String rawMarginTextAlign = rootJsonObject.getString("marginTextAlign");
  switch (rawMarginTextAlign) {
    case "LEFT":
      marginTextAlign = LEFT;
      break;
    case "CENTRE":
    case "CENTER":
      marginTextAlign = CENTER;
      break;
    case "RIGHT":
      marginTextAlign = RIGHT;
      break;
  }
  
  JSONArray rawBackgroundColour = rootJsonObject.getJSONArray("backgroundColor");
  backgroundColour = color(rawBackgroundColour.getInt(0), rawBackgroundColour.getInt(1), rawBackgroundColour.getInt(2));
  
  JSONArray rawMarginColour = rootJsonObject.getJSONArray("marginColor");
  marginColour = color(rawMarginColour.getInt(0), rawMarginColour.getInt(1), rawMarginColour.getInt(2));
  
  JSONArray rawAthletes = rootJsonObject.getJSONArray("athletes");
  athletes = new Athlete[rawAthletes.size()];
  barHeight = (height - 10 - (rawAthletes.size() - 2) * 10) / rawAthletes.size();
  fontSize = round(barHeight * 1.1);
  eliminatedTextOffset = fontSize * 8;
  
  JSONObject rawAthlete;
  JSONArray rawAthleteColour;
  for (int i = 0; i < rawAthletes.size(); i++) {
    rawAthlete = rawAthletes.getJSONObject(i);
    rawAthleteColour = rawAthlete.getJSONArray("color");
    athletes[i] = new Athlete(
      rawAthlete.getString("name"),
      color(rawAthleteColour.getInt(0), rawAthleteColour.getInt(1), rawAthleteColour.getInt(2)),
      rawAthlete.getInt("startPoints"),
      rawAthlete.getInt("earnedPoints")
    );
  }
}

void setAthleteNewPlaces() {
  Athlete[] newAthletes = Arrays.copyOf(athletes, athletes.length);
  
  Arrays.sort(newAthletes, new Comparator<Athlete>() {
    @Override
    public int compare(Athlete athlete1, Athlete athlete2) {
      return athlete2.newPoints - athlete1.newPoints;
    }
  });
  
  maxScore = newAthletes[0].newPoints;
  
  for (int i = 0; i < newAthletes.length; i++) {
    newAthletes[i].newPlace = i;
  }
}

void outlineText(String text, color mainColour, color outlineColour, int posX, int posY) {
  fill(outlineColour);
  for(int i = -1; i < 2; i++){
    text(text, posX + i, posY);
    text(text, posX, posY + i);
  }
  fill(mainColour);
  text(text, posX, posY);
}

void setup() {
  size(1280, 720);
  
  parseJsonData();
  
  Arrays.sort(athletes, new Comparator<Athlete>() {
    @Override
    public int compare(Athlete athlete1, Athlete athlete2) {
      return athlete2.startPoints - athlete1.startPoints;
    }
  });
  
  setAthleteNewPlaces();

  textFont(mainFont, fontSize);
  noStroke();
  frameRate(60);
}

void draw() {
  background(backgroundColour);

  final int duration = 1200; // The duration (in ticks) of the animation

  final int barGrowDelay = 180; // The number of ticks until the bars start growing
  final int barShuffleTick = 480; // The value of tick where the bars finish growing and start moving
  final int barMoveDuration = 300; // The number of ticks it takes for the bars to move
  
  final int leftMarginWidth = 150; // The width of the left grey margin
  final int rightMarginWidth = 150; // The width of the 'right margin' where bars cannot extend into
  
  final int maxBarWidth = width - leftMarginWidth - rightMarginWidth;

  if (tick < duration) {
    // Draw left margin
    fill(marginColour);
    rect(0, 0, leftMarginWidth, height);
    textAlign(marginTextAlign);
    fill(255);

    // Write left margin text
    for (int i = 0; i < athletes.length; i++) {
      text((i + 1) + getOrdinalPostfix(i + 1), leftMarginWidth / 2, barHeight + (barHeight + 10) * i);
    }
    
    tick++;    
    if (tick == barShuffleTick + barMoveDuration + eliminatedTextDelay) {
      aliveAthletes -= athletesToEliminate;
    }

    if (tick < barShuffleTick) {
      progress = max((float(tick) - barGrowDelay) / barMoveDuration, 0);
    } else {
      progress = -cos(constrain((float(tick) - barShuffleTick) / barMoveDuration, 0, 1) * PI) / 2 + 0.5;
    }

    int barSizeX, barSizeY;
    for (int i = 0; i < athletes.length; i++) {
      fill(athletes[i].colour); 

      if (tick < barShuffleTick) {
        barSizeX = int(maxBarWidth * lerp(athletes[i].startPoints, athletes[i].newPoints, progress) / maxScore);
        barSizeY = (barHeight + 10) * i;
      } else {
        barSizeX = int(maxBarWidth * (float)athletes[i].newPoints / maxScore);
        barSizeY = int(lerp(i, athletes[i].newPlace, progress) * (barHeight + 10));
      }
      
      rect(leftMarginWidth, barSizeY + 5, barSizeX, barHeight);
      textAlign(LEFT);
      
      color accentColour = getLuminance(athletes[i].colour) < 0.5 ? color(255) : color(0);
      if (showTextOutlines) {
        outlineText(athletes[i].name, athletes[i].colour, accentColour, leftMarginWidth + barSizeX + 5, barHeight + barSizeY);  
      } else {
        text(athletes[i].name, leftMarginWidth + barSizeX + 5, barHeight + barSizeY);
      }

      fill(accentColour);
      textAlign(RIGHT);
      if (tick < barShuffleTick) {
        text(String.format("%,d", round(lerp(athletes[i].startPoints, athletes[i].newPoints, progress))), leftMarginWidth + barSizeX, barHeight + barSizeY);
      } else {
        text(String.format("%,d", athletes[i].newPoints), leftMarginWidth + barSizeX, barHeight + barSizeY);
      }

      if (athletes[i].newPlace >= aliveAthletes) {
        fill(255, 25, 0);
        textFont(eliminatedTextFont, round(fontSize * 1.1));
        textAlign(LEFT);
        text("ELIMINATED", athletes[i].name.length() * 20 + barSizeX + eliminatedTextOffset, barSizeY + barHeight);
        textFont(mainFont, fontSize);
      }
    }
  }
}
