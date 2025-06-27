# Soccer Scores

## Overview
This command-line application is intended to read soccer score data line-by-line. When the application decides that the day is finalized as in all games have been played and scores recorded, it prints up to top 3 teams with their names and points by match day.

This reads data from a file or stdin and sends output to the console. To run this application with `sample-input.txt` as the data provided, pull the repository and run 
```sh
./run # stdin prompt will wait and receive score data
```
or
```sh
cat sample-input.txt | ./run
```
or
```sh
./run < sample-input.txt
```
or
```sh
./run sample-input.txt
```

Console output as stdout will display the expected result mentioned in `expected-output.txt`. As the `sample-input.txt` receives more valid score lines, stdout will add more expected results.

## Design
This application would contain a main `./run` executable script that would allow receiving a file with all the scores as an argument `./run sample-input.txt`. Alternatively, you could call `./run` and use the console prompt to enter data or use a file with score data and pipe/redirect in the data to `./run` script. This calls the `Tournament.run` class to execute the start of main logic.

## Dependencies
In order to run this script, the machine will need ruby `2.7.7`. It is locked in `.ruby-version`. This has been developed on a unix system and not been tested in windows. Gemfile contains dependencies to run tests (`bin/tests`) and linter (`bin/lint`). However, to run the main application, ruby is the only dependency.

## Assumptions and Constraints
Input string for a game result is assumed to be in the format of
```
First Team Name SCORE, Second Team Name SCORE
```
Name of teams can contain case insensitive english letters with spaces. Any other name is assumed to be invalid. SCORE is assumed to be a numeric digit with no quotes or special characters around it. A sample would look like
```
AFC Richmond 2, West Ham United FC 0
```

Any invalid result string would be completely ignored. If names are displayed with inconsistent cases, they would considered different teams.

End of the day is assumed to be when a new empty line is encountered instead of a result line. Also, if a team has played a match in a given day and another score is presented, we finalize the scores for the previous day and assume the new score is for the next day.

## Architecture
This application has `./run` executable script as the entrypoint. It uses ruby class Tournament and Team to implement the logic.

Tournament keeps track of matchday, all the teams that are playing and the teams playing currently. This class reads the input (either via file or stdin) and processes the result line by line. It determines whether the score is for a new team or a team that has played already. Determines and assigns/updates points based off the game result. Also, increments the matchday based off of assumptions described above.

Team objects are used by tournament for representing team entities. This class knows about the team's name, points and current scores. Its major functionality includes interacting with other team object to determine points based off of the game result. Points are persisted and score attribute is used on a rolling basis around match_results.

### Detailed System Design
For ensuring the need to constantly able to read the input, an infinite loop is used un `Tournament.run` class method. This allows for input stream to be read and application to process the result until the program is interrupted.

To determine whether we need to increment matchday, `teams_played_today` SortedSet is used. This has dual purpose. Since a set only adds unique elements, we can check if a team has played today already or not. If it has, we can use the sorted_set to pick the first three sorted teams and display the matchday results and then clear the set out. Finally, add the teams that just played that triggered this increment. In order for SortedSet to work with team objected, a combined comparison operator `<=>` has been defined. This orders teams and puts precedence to the team with higher point. If the two teams being compared have the same points, it sorts the team name alphabetically.

For keeping track of all the teams that have played, a `teams` Hash is used with key as the name and value as the team object. A new team object is created if `teams` Hash can't find a team with the team name. Here the assumption is same team will keep their names and cases consistent when entering the result.

## Instructions for tests and linting
RSpec framework is used in writing unit tests. This also uses `faker` gem to generate random values. To run the tests, make sure `bundle` is run successfully. Then run 
```sh
bin/test
```

Standard is used for linting. This gem uses rubocop behind the scenes and is easy to setup. To run the linter, make sure `bundle` is run successfully. Then run
```sh
bin/lint
```
