void drawStaff(float y1, float y2) {
  float totalHeight = y2 - y1;

  // Dynamic calculations for the treble and bass staves
  int numLines = 5; 
  float gapRatio = 2.0; 
  float totalGutterHeight = totalHeight / (2 + gapRatio); 
  float staffHeight = totalGutterHeight; 
  float gapHeight = totalGutterHeight * gapRatio; 
  float innerGaps = staffHeight / (numLines - 1); 

  // Draw vertical margins
  strokeWeight(2);
  stroke(#090c02);
  line(leftMargin, y1, leftMargin, y2); // Left margin line
  line(rightMargin, y1, rightMargin, y2); // Right margin line

  // Draw measure lines (from top of treble staff to bottom of bass staff)
  strokeWeight(1);
  stroke(#090c02);
  for (int x = 0; x <= 8; x++) { // 8 measure divisions (9 vertical lines total)
    float xPos = leftMargin + x * measureLength; // Offset by leftMargin
    line(xPos, y1, xPos, y2); // Extend measure lines from y1 to y2
  }

  // Draw staff lines for treble staff
  float trebleEndY = 0;
  for (int i = 0; i < numLines; i++) {
    float y = y1 + i * innerGaps;
    line(leftMargin, y, rightMargin, y);
    trebleEndY = y; // Update the end Y-coordinate of the treble staff
  }

  // Calculate the starting Y-coordinate for the bass staff
  float bassStartY = trebleEndY + gapHeight;

  // Draw staff lines for bass staff
  for (int i = 0; i < numLines; i++) {
    float y = bassStartY + i * innerGaps;
    line(leftMargin, y, rightMargin, y);
  }

  // Call drawNotes for each measure
  drawNotes(y1, trebleEndY, bassStartY, y2);
}

void drawNotes(float trebleY1, float trebleY2, float bassY1, float bassY2) {
  int numMeasures = 8; // Number of measures
  int notesPerMeasure = 4; // Number of notes per measure
  float interval = measureLength / notesPerMeasure; // Spacing between notes in a measure
  float gutterY1 = trebleY2; // The bottom of the treble staff
  float gutterY2 = bassY1;   // The top of the bass staff
  float range = 10; // Range for notes to extend above/below the staves
  ArrayList<Note> trebleNotes = new ArrayList<>();
  ArrayList<Note> bassNotes = new ArrayList<>();

  for (int i = 0; i < numMeasures; i++) {
    float measureStartX = leftMargin + i * measureLength;

    // Generate notes within the treble staff
    for (int j = 0; j < notesPerMeasure; j++) {
      float noteX = measureStartX + j * interval + interval / 2; // Clamp note to interval center
      float noteY = random(trebleY1 - range, trebleY2 + range); // Random Y
      boolean isEighth = random(1) > 0.5; // Randomly decide if the note is an 8th note
      Note note = new Note(noteX, noteY, 20, isEighth);
      trebleNotes.add(note);
      drawNote(noteX, noteY, 20, 3, gutterY1, gutterY2, trebleY1, bassY2);
    }

    // Generate notes within the bass staff
    for (int j = 0; j < notesPerMeasure; j++) {
      float noteX = measureStartX + j * interval + interval / 2; // Clamp note to interval center
      float noteY = random(bassY1 - range, bassY2 + range); // Random Y
      boolean isEighth = random(1) > 0.5; // Randomly decide if the note is an 8th note
      Note note = new Note(noteX, noteY, 20, isEighth);
      bassNotes.add(note);
      drawNote(noteX, noteY, 20, 3, gutterY1, gutterY2, trebleY1, bassY2);
    }
  }

  // Connect 8th notes
  connectEighthNotes(trebleNotes);
  connectEighthNotes(bassNotes);
}

void connectEighthNotes(ArrayList<Note> notes) {
  strokeWeight(3); // Bold line for 8th notes
  stroke(#090c02);

  int start = -1; // Index of the start of the current 8th note group
  for (int i = 0; i < notes.size(); i++) {
    Note note = notes.get(i);

    // Check if the note is an 8th note
    if (note.isEighth) {
      if (start == -1) {
        // Mark the start of a new group
        start = i;
      }
    } else {
      // If the note is not an 8th note and we were in a group, finalize the group
      if (start != -1) {
        drawEighthNoteConnection(notes, start, i - 1); // Connect up to the note before this one
        start = -1; // Reset the start index
      }
    }
  }

  // Finalize any remaining group at the end of the list
  if (start != -1) {
    drawEighthNoteConnection(notes, start, notes.size() - 1);
  }
}


void drawEighthNoteConnection(ArrayList<Note> notes, int start, int end) {
  // Find the topmost Y-coordinate in the sequence
  float topMostY = Float.MAX_VALUE;
  for (int i = start; i <= end; i++) {
    topMostY = min(topMostY, notes.get(i).y);
  }

  // Calculate the slope of the connecting line based on the first and last notes
  float dx = notes.get(end).x - notes.get(start).x; // Difference in x-coordinates
  float dy = notes.get(end).y - notes.get(start).y; // Difference in y-coordinates
  float slope = dy / dx; // Slope of the line

  // Adjust the connecting line to start at topMostY
  float adjustedStartY = topMostY; // The topmost point becomes the start Y
  float adjustedEndY = adjustedStartY + slope * dx; // Adjust the end Y based on the slope
  strokeWeight(2);
  // Draw the horizontal connecting line
  line(notes.get(start).x, adjustedStartY, notes.get(end).x, adjustedEndY);

  strokeWeight(1);
  // Draw vertical lines connecting each note to the sloped connecting line
  for (int i = start; i <= end; i++) {
    Note note = notes.get(i);

    // Calculate the Y position of the connecting line at the current note's X position
    float yOnConnectingLine = adjustedStartY + slope * (note.x - notes.get(start).x);

    // Draw a vertical line from the note's top to the connecting line
    line(note.x, note.y, note.x, yOnConnectingLine);
  }
}


void drawNote(float x, float y, float h, int colorIdx, float gutterY1, float gutterY2, float trebleY1, float bassY2) {
  stroke(p[colorIdx]);
  strokeWeight(1);
  line(x, y, x, y + h); // Draw the vertical line of the note

  // Draw the thicker bottom part of the note
  for (int i = 0; i < 5; i++) {
    line(x - i, (y + h) - 5, x - i, y + h);
  }

  // Only draw the horizontal line if the thick block part of the note falls in the gutter
  if ((y + h - 5) >= gutterY1 && (y + h) <= gutterY2) {
    strokeWeight(1);
    stroke(#090c02);
    line(x - 10, (y + h) - 2.5, x + 5, (y + h) - 2.5); // Horizontal cross line in gutter
  }

  // Draw horizontal line for notes above the treble staff
  if ((y + h) < trebleY1) {
    strokeWeight(1);
    stroke(#090c02);
    line(x - 10, (y + h) - 2.5, x + 5, (y + h) - 2.5); // Horizontal cross line above treble staff
  }

  // Draw horizontal line for notes below the bass staff
  if ((y + h) > bassY2) {
    strokeWeight(1);
    stroke(#090c02);
    line(x - 10, (y + h) - 2.5, x + 5, (y + h) - 2.5); // Horizontal cross line below bass staff
  }
}
