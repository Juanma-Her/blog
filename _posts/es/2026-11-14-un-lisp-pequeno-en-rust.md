---
title: "Un intérprete de Lisp pequeño en Rust"
date: 2026-11-14
description: "Tokenizar, parsear, evaluar: un intérprete que funciona en unas 200 líneas."
tags: [rust, interpreters]
ref: tiny-lisp
---

Un intérprete de Lisp es un buen primer proyecto de lenguajes: la sintaxis es mínima, así que casi todo el trabajo va a las partes que importan. Este post de ejemplo es la traducción del post en inglés.

## Tokenizar

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

La evaluación recorre el árbol una vez: $$O(n)$$ para $$n$$ nodos.
