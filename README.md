# Algathlon Leaderboard

## Instructions

- To use with your Algathlon, change the properties inside the `athletes` array in data.json.
- Each athlete must have the following properties:
    - `name`
    - `color` (RGB)
    - `startPoints` (the points at the beginning of the animation)
    - `earnedPoints` (the points earned this event)
- You must also set `aliveAthletes` to the number of alive athletes in the competition *before* this event. 
- If multiple athletes will be eliminated, change the value of `athletesToEliminate`.

- If you want to change the font, open leaderboard.pde in Processing and go to Tools > Create Font. Pick a font and a font size, note the file name and press OK. Go to data.json and change `mainFont` and/or `eliminatedTextFont` to the file name of the new font you picked.
