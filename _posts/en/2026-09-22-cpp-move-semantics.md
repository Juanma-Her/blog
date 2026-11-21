---
title: "Move semantics without the hand-waving"
date: 2026-09-22
description: "What std::move actually does, and the three cases where it matters."
tags: [cpp]
ref: cpp-move-semantics
updated: 2026-10-02
---

Sample post for the C/C++ topic, with an update date.

```cpp
std::vector<int> make() {
    std::vector<int> v(1'000'000);
    return v; // moved or elided, never copied
}
```
