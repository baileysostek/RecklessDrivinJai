# RecklessDrivinJAI

This is a transpilation / re-implementation of the original source code of Reckless Drivin into the Jai programming language. I have never ported a game before and would like to start with this project. Reckless Drivin was a childhood staple for my family on our iMac G3 and I would really like to play the game again. 

I am planning on staying true to the original game in mechanics and feel, but want to update the old OpenGL fixed function pipeline code to run on modern graphics cards.

# Jai specific instructions.

To build the game, from the root directory of the project run `jai build.jai` and the executable `drivin` will be produced. 

# Timeline / Progress
3 - 7 - 24 | Created an SDL window and setup the project. 

# RecklessDrivin

This is the original source code for the mac shareware game "Reckless Drivin'", originally released in 2000.

The source code is in C, project.mcp is a CodeWarrior project file which was used to build it. To be able to upload this to git, Line endings have been converted to Unix style, and the resource forks of the rsrc files have been moved to the data fork. You may need to revert these changes before being able to build it on a classic Macintosh.
