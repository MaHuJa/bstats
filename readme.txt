This is the uplink extension for bstats.

Bstats, written by Spyder, is a script suite for arma 2 and 3 which does a far better job than the built-in system for determining what really happened in a game (tying it to players), and providing some sort of decent scoring ability. 

From that project, we grew armalive which uses that information and makes it available on the web. To get it out the game we used a2u (arma 2 uplink) which even worked with linux servers. Problem is, a2u was basically only a hack, in particular its two-way mode. It also stopped working and needed a non-trivial fix to get it back in shape.

Then came arma3, including release, and I decided to switch to an extension. This will make it easier (no need to set up and monitor a separate application) and more reliable (especially bringing data into the game again) at the cost of extending a big FU to linux server admins, who were always second-rate citizens in the armaverse. (Get it together, BI!)


- Loading : No need to load arma3 to test the extension. This will do the job, allowing me to iterate that much faster.
- Bstats : The extension itself, to be put into the addon folder

