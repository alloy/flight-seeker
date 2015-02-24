# Flight Seeker

* Requires a QPX Express API key: https://developers.google.com/qpx-express/v1/prereqs#getaccount
* QPX Express reference: https://developers.google.com/qpx-express/v1/trips/search

## Usage

Currently the search query is hardcoded, this will need to move to the CLI.

```
$ bundle install
$ env QPX_EXPRESS_API_KEY=SECRET bundle exec ruby flight-seeker.rb --sort=-2,-4,9
```

Example output sorted by segments (descending), level mileage (descending), and outbound duration (ascending):

```
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| Price   | Segments | Mileage | Level Mileage | CPM    | Award Mileage | CPM    | Outbound                                            | Duration | Inbound                     | Duration |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €770.01 | 6        | 8643    | 2309.5        | 33.34¢ | 6631.0        | 11.61¢ | AMS-(AF/L)->BSL-(AF/L)->CDG-(AF/V)->BOS-(AF/V)->LGA | 14h44m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €770.01 | 6        | 8643    | 2309.5        | 33.34¢ | 6631.0        | 11.61¢ | AMS-(KL/L)->BSL-(AF/L)->CDG-(AF/V)->BOS-(AF/V)->LGA | 14h44m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9898    | 2536.25       | 28.95¢ | 7485.25       | 9.81¢  | AMS-(KL/L)->CDG-(AF/V)->MSP-(AF/V)->LGA             | 16h29m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9898    | 2536.25       | 28.95¢ | 7485.25       | 9.81¢  | AMS-(AF/L)->CDG-(AF/V)->MSP-(AF/V)->LGA             | 17h14m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9898    | 2536.25       | 28.95¢ | 7485.25       | 9.81¢  | AMS-(KL/L)->CDG-(AF/V)->MSP-(AF/V)->LGA             | 17h14m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9898    | 2536.25       | 28.95¢ | 7485.25       | 9.81¢  | AMS-(AF/L)->CDG-(AF/V)->MSP-(AF/V)->LGA             | 17h44m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9898    | 2536.25       | 28.95¢ | 7485.25       | 9.81¢  | AMS-(KL/L)->CDG-(AF/V)->MSP-(AF/V)->LGA             | 17h44m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9816    | 2515.75       | 29.19¢ | 7423.75       | 9.89¢  | AMS-(KL/L)->CDG-(AF/V)->ATL-(AF/V)->LGA             | 16h19m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €734.35 | 5        | 9816    | 2515.75       | 29.19¢ | 7423.75       | 9.89¢  | AMS-(AF/L)->CDG-(AF/V)->ATL-(AF/V)->LGA             | 16h19m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €835.5  | 5        | 9674    | 2475.75       | 33.75¢ | 7312.75       | 11.43¢ | AMS-(KL/L)->LHR-(KL/V)->MSP-(KL/V)->LGA             | 16h57m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €835.5  | 5        | 9674    | 2475.75       | 33.75¢ | 7312.75       | 11.43¢ | AMS-(KL/L)->LHR-(KL/V)->MSP-(KL/V)->LGA             | 18h34m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €835.5  | 5        | 9674    | 2475.75       | 33.75¢ | 7312.75       | 11.43¢ | AMS-(KL/L)->LHR-(KL/V)->MSP-(KL/V)->LGA             | 18h47m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €800.85 | 5        | 9791    | 2475.25       | 32.35¢ | 7370.75       | 10.87¢ | AMS-(KL/L)->DUS-(KL/V)->ATL-(KL/V)->LGA             | 17h9m    | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
| €827.5  | 5        | 9615    | 2461.0        | 33.62¢ | 7268.5        | 11.38¢ | AMS-(KL/L)->LHR-(KL/V)->ATL-(KL/V)->LGA             | 16h32m   | LGA-(KL/V)->DTW-(KL/V)->AMS | 10h55m   |
+---------+----------+---------+---------------+--------+---------------+--------+-----------------------------------------------------+----------+-----------------------------+----------+
```
