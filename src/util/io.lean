import system.io

namespace io

meta def fail' {α} (fmt : format) : io α := io.fail $ format.to_string fmt
meta def put_str_ln' : Π (fmt : format), io unit := io.put_str_ln ∘ format.to_string

end io


section io
open interaction_monad interaction_monad.result
namespace io

meta def run_tactic' {α} (tac :tactic α) : io α := do {
  io.run_tactic $ do {
    result ← tactic.capture tac,
    match result with
    | (success val _) := pure val
    | (exception m_fmt pos _) := do {
      let fmt_msg := (m_fmt.get_or_else (λ _, format!"none")) (),
      let msg := format!"[io.run_tactic'] {pos}: tactic failed\n-------\n{fmt_msg}\n-------\n",
      tactic.trace msg,
      tactic.fail msg
    }
    end
  }
}

end io
end io


-- convenience function for command-line argument parsing
meta def list.nth_except {α} : list α → ℕ → string → io α := λ xs pos msg,
  match (xs.nth pos) with
  | (some result) := pure result
  | none := do
    io.fail' format!"must supply {msg} as argument {pos}"
  end