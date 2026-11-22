---
title: "Writing a tiny Lisp interpreter in Rust"
date: 2026-11-14
description: "Tokenize, parse, evaluate: a working interpreter in about 200 lines."
tags: [rust, interpreters]
ref: tiny-lisp
hero_code:
  lang: scheme
  code: |
    (define (fact n)
      (if (= n 0) 1
          (* n (fact (- n 1)))))
---

A Lisp interpreter is a good first language project: the syntax is tiny, so most of the work goes into the parts that matter. This sample post exercises the elements a real post uses.

## Tokenizing

The tokenizer splits the input on parentheses and whitespace.

```rust
pub fn tokenize(src: &str) -> Vec<String> {
    src.replace('(', " ( ")
        .replace(')', " ) ")
        .split_whitespace()
        .map(str::to_owned)
        .collect()
}
```
{: data-file="src/lexer.rs"}

> Parentheses are padded with spaces first, so `split_whitespace` does all the work.
{: .note}

## How fast is it?

Evaluation walks the tree once, so it runs in $$O(n)$$ for $$n$$ nodes. The factorial above computes

$$
n! = \prod_{k=1}^{n} k
$$

with one recursive call per factor. A literal dollar sign stays a dollar sign: this post cost $0 to host.
