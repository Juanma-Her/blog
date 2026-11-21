---
title: "Profiling Python before rewriting it in C"
date: 2025-12-03
description: "cProfile and py-spy found the slow part in an afternoon; the rewrite was not needed."
tags: [python]
ref: python-profiling
---

Before reaching for C, measure. Run the script under `cProfile` and sort by cumulative time:

```sh
python -m cProfile -s cumtime solve.py | head -20
```

In our case, 80% of the time went into building the same lookup table on every call. Caching it made the script fast enough, and the C rewrite never happened.
