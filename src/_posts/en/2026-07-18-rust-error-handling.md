---
title: "Error handling without the boilerplate"
date: 2026-07-18
description: "The ? operator, thiserror and anyhow: which one to reach for, and when."
tags: [rust]
ref: rust-error-handling
---

Sample post, so the Rust topic has two posts and the "More on Rust" band shows.

| Crate | Use it in | Gives you |
|-------|-----------|-----------|
| `thiserror` | Libraries | Typed errors callers can match on |
| `anyhow` | Binaries | One error type with context |

```rust
fn read_config(path: &Path) -> anyhow::Result<Config> {
    let text = fs::read_to_string(path).context("reading config")?;
    Ok(toml::from_str(&text)?)
}
```

1. Start with `?` everywhere.
2. Add context where a reader would ask "while doing what?".
