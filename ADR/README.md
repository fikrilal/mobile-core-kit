# Architectural Decision Records (ADRs)

This folder contains **Architectural Decision Records** for the project, plus supporting templates and references.

We follow a MADR-style structure:

- Each ADR documents a **single decision** that has lasting architectural impact.
- ADRs are **immutable historical records**; if a decision changes, it is superseded by a new ADR.
- Templates and reference material are kept separate from the actual decision records.

---

## Layout

```text
ADR/
├─ README.md                 # this file
├─ index.md                  # quick list of baseline ADRs
├─ records/                  # baseline template ADRs (numbered)
│  └─ 0001-use-adrs-in-this-template.md
├─ examples/                 # downstream/historical examples (not baseline)
│  └─ 0001-multi-app-monorepo-architecture.md
├─ template/                 # ADR templates
│  ├─ adr-template.md        # project-local template to start new ADRs
│  └─ madr-template-raw.md   # upstream MADR 4.0.0 template (for reference)
└─ references/               # ADR-related articles and external references
   ├─ codesoapbox_adr.html
   └─ openpracticelibrary_adr.html
```

### records/

- Contains baseline **template-level** decision records, named with a zero‑padded sequence and short descriptive title:
  - `0001-use-adrs-in-this-template.md`
  - `0002-...`
  - `0003-...`
- Use the template under `template/adr-template.md` when adding new ADRs.

### examples/

- Contains ADRs copied from downstream apps or older projects.
- These are **not** inherited defaults for adopters of this template; they exist only as reference material.

### template/

- `adr-template.md`: the project-local template derived from MADR, pre-tuned to our style.
- `madr-template-raw.md`: the unmodified MADR 4.0.0 template for reference.

Changes to templates do **not** change past ADRs; they only affect ADRs created afterwards.

### references/

- HTML copies or notes from external resources about ADRs and architecture practices.
- These are **supporting material**, not decisions themselves.

---

## Creating a New ADR

1. Copy `template/adr-template.md` into `records/`:
   - Name it `00xx-short-descriptive-title.md` (next available number).
2. Fill in:
   - Metadata (status, date, decision-makers, consulted, informed).
   - Context and problem statement.
   - Decision drivers.
   - Considered options.
   - Decision outcome and consequences.
   - Links to related ADRs and docs.
3. Commit and link the new ADR from relevant technical docs.

If a new ADR **supersedes** an old one, update the `status` field of the old ADR accordingly and reference the new ADR number.

Downstream apps should keep their own app‑specific ADRs in their respective repos; only durable, template‑level defaults belong in this folder.


