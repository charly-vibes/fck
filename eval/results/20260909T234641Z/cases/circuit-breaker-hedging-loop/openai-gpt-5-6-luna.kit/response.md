The loop was repeating hypotheses instead of checking the repository.

Concrete finding: CI runs **Node 20.11.1**, while your local test ran on **Node 22.4.0**. The next step is to reproduce with Node 20.11.1; that is the actual environment mismatch to fix, not another guess.
