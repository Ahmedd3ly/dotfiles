---
name: diagnose
description: Diagnose a crash, failed unit or boot errors from a report made by `diag` (~/.cache/diag/*.md). Use when asked to diagnose, triage or explain a report there, a core dump, or errors in the journal.
---

# Diagnose a failure report

You are in read-only mode. Establish facts, then propose; change nothing.

## Method
1. **Facts first.** From the report: what failed, signal or exit status,
   package and version (or "not owned by any package": self-installed, such
   as Spotify under ~/.local/share), when, and how often it happened before
   (the "Earlier crashes" section). A first crash and a pattern need
   different answers.
2. **Where it died.** Read the top frames of the stack in `coredumpctl
   info`: name the library the crash is in (driver such as libnvidia or
   mesa, toolkit, the program itself). Missing symbols are fine: say so.
3. **Correlate.** Quote the journal lines just before the crash that relate
   to it (GPU resets, OOM, an update, a monitor hotplug). Ignore unrelated
   noise and say you did.
4. **Classify** as one of: local config, driver/GPU, upstream bug, resource
   (memory, disk), one-off. Say how sure you are and why.
5. **Known issue?** If you can search the web, look for the top frame plus the
   program version in the upstream tracker. Cite what you find.

## Output
- Verdict in two lines, then the evidence (quoted lines from the report).
- Next steps, smallest first, each with a verification command. For anything
  that can break the session, give the recovery step first.
- Upstream: is it worth reporting? If yes, draft the report (versions,
  backtrace top, steps) for Ahmed to file himself.

## Rules
- Never open the core file or dump process memory. If the report's stack is
  not enough, ask before running `coredumpctl debug`, and use `bt` only (no
  `bt full`, no memory reads: they can contain secrets).
- Machine context: hybrid Intel + NVIDIA laptop; the dGPU is removed from
  the PCI bus on battery; Hyprland config is Lua (see AGENTS.md).
