## What does this change?



## Why?



## Checklist

- [ ] Commits are signed off (DCO): `git commit -s`
- [ ] `swift build` and `swift test` pass locally
- [ ] New logic has tests
- [ ] I did **not** add any code that links against an OpenFOAM library
      (see `Documentation/adr/0002` — OpenFOAM is subprocess-only)
- [ ] I did **not** fabricate progress, results, or convergence data
      anywhere in the UI (see `Documentation/adr/0003` and the project's
      "no fake functionality" principle)
- [ ] If this changes architecture, licensing, or another decision that
      future contributors need the reasoning behind, I added/updated an
      ADR in `Documentation/adr/`
- [ ] I checked/updated `PROJECT_STATE.md` (Development Journal + Session
      Checkpoint) if this is a meaningful development step

## Related issue(s)

