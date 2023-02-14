# lean-gym

`Lean-gym` is a package that is used to interact with Lean programmatically through a Read Evaluate Print Loop (REPL).


## Dependencies
Lean 3 and mathlib need to be installed before you can use lean-gym.
The same can be installed from [here](https://leanprover-community.github.io/get_started.html).


## Setup
Clone the [lean-gyn](https://github.com/openai/lean-gym) github repo and execute the setup file.
```
bash ./scripts/setup.sh
```

## Interaction with user
To start the repl we have to run the following command
```bash
$ lean --run src/repl.lean
```

The interaction by the user is through a terminal where the REPL is started by running the `src/repl.lean` file of the lean-gym. And then, user can start the proof search by using commands like `init_search`, `run_tac`, and `clear_search`.


- `init_search`: This takes input as a declaration name and namespaces (declaration names and open namespaces are available in the `data/` directory) and and initializes the search for the given declaration (theorem) set the env with open namespaces to it and generate a new tactic state and returns the `search_id` and `tactic_state_id`.
- `run_tac`: it takes the `search_id`, `tactic_state_id`, and a `tactic` as input and applies the tactic to the current tactic state and gets a new goal or results into an error. If there is no more subgoals, check that the produced proof is valid.
- `clear_search`: This command takes `search_id` as input and clears the states related to that search_id by removing the table associated with it.


### Some commands in use
- Initalise the proof search for the theorem `int.prime.dvd_pow'`
```
["init_search", ["int.prime.dvd_pow'", ""]]
{"error":null,"proof_steps":[],"search_id":"1","tactic_state":"⊢ ∀ {n : ℤ} {k p : ℕ}, nat.prime p → ↑p ∣ n ^ k → ↑p ∣ n","tactic_state_id":"0"}
```

- Run tactic `intros`
```
["run_tac",["1","0","intros"]]
{"error":null,"proof_steps":[],"search_id":"1","tactic_state":"n : ℤ,\nk p : ℕ,\nhp : nat.prime p,\nh : ↑p ∣ n ^ k\n⊢ ↑p ∣ n","tactic_state_id":"1"}
```

- Run tactic `rw int.coe_nat_dvd_left`
```
["run_tac",["1","1","rw int.coe_nat_dvd_left"]]
{"error":null,"proof_steps":[],"search_id":"1","tactic_state":"n : ℤ,\nk p : ℕ,\nhp : nat.prime p,\nh : ↑p ∣ n ^ k\n⊢ p ∣ n.nat_abs","tactic_state_id":"2"}
```

- Run tactic `exact int.prime.dvd_pow hp h`
```
["run_tac",["1","2","exact int.prime.dvd_pow hp h"]]
{"error":null,"proof_steps":[],"search_id":"1","tactic_state":"no goals","tactic_state_id":"3"}
```

- Clear the proof search with `search_id` = 1
```
["clear_search",["1"]]
{"error":null,"proof_steps":[],"search_id":"1","tactic_state":null,"tactic_state_id":null}
```
- When a tactic state is reached with no left goals, some custom logic is run to check that the resulting proof's type matches the top level goal type and does not rely on `sorry`.


## Interaction through Python
[Here](https://github.com/rahul3613/lean-gym/blob/main/py_gyn.ipynb) is a jupyter notebook with sample code for using the lean-gym from python.

## Interaction with Lean
`src/repl.lean` is the file responsible for handling the Read Evaluate Print Loop.
It imports all the results from mathlib (`import all`) and necessary packages from the lean. 
Then a structure `LeanREPLState` is created to store and handle the proof states. 
`LeanREPLState` is initialized with a new state for the decleration (theorem name) passed in `init_search` command.

For every new `run_tactic` command, the current state for the search id is accessed from the LeanREPLState. Then the requested tactic is applied to the current state, to get a new state. After application of each new tactic number of new goals is counted if the the number of new goals in 0 then `finalize_proof` function is called to verify the proof generated, and if the number of goals is more than 0 then the new goals are given in output.

## The REPL
1. Read a line from the terminal.
2. Parse the request to get the `command` and other info like `search_id`, `tactic_state_id`, `tactic`.
3. Use the handle functions like `handle_init_search`, `handle_run_tac`, and `handle_clear_search` to execute the command parsed and update the state accordingly.
4. After execution, `LeanREPLResponse.to_json` function converts the result to JSON format.
5. Output the result.
6. Go back to step 1.
