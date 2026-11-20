""" build-time text normalization (2026-10-21, owner-ruled).

Two artifact families, measured before ruling (2026-10-21 census on
the 48,033-chunk store):

* LIGATURES — 1,243 chunks (2.6%) carry Unicode ligature presentation
  forms (ﬀ ﬁ ﬂ ﬃ ﬄ, U+FB00..FB04) left by PDF extraction; the words
  (flux, file, field, first, coefficients, …) never match their
  plain-spelled query.  Folding is mechanical and zero-ambiguity —
  every presentation form has exactly one intended spelling.
* HYPHENATION — 840 chunks (1.75%) carry ``word-`` + line break +
  ``continuation`` splits of corpus vocabulary (temperature 32x,
  separatrix 28x, transport 25x, …).  The hyphen-at-line-end marker is
  unambiguous as a SPLIT marker, but joining is only safe with
  EVIDENCE: a line-broken real compound (``Monte-``/``Carlo``) must
  not become ``MonteCarlo``.  Rule: join only when the joined form
  already exists as a corpus token — the spelling is proven by the
  corpus itself before it is written into it.

NOT done (ruled out, 2026-10-21): space-split repair — no marker
distinguishes ``sche me`` from two real adjacent words; 
unconditional recovery enumeration is that family's mitigation.

The transform is a pure function of the chunk texts: deterministic,
reversible in principle (log the counts, never the originals), and
applied BEFORE the store is written so every face reads the same
normalized bytes.  Chunk IDs are untouched — they derive from
provenance (source, page, paragraph index), never text.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

from askthedocs import store

# Unicode ligature presentation forms -> their plain spellings.
# Deliberately ONLY U+FB00..FB04: other compatibility characters
#(ß, ſ, …) are real letters with real query-time handling, not
# typographic artifacts.
LIGATURES = {
    "ﬀ": "ff",   # ﬀ
    "ﬁ": "fi",   # ﬁ
    "ﬂ": "fl",   # ﬂ
    "ﬃ": "ffi",  # ﬃ
    "ﬄ": "ffl",  # ﬄ
}

# word + hyphen + (optional CR) + line break + word — the extraction
# marker for an end-of-line hyphenation split.  Both sides must be
# token runs (letters/digits); anything else is left untouched.
_HYPHEN_SPLIT = re.compile(r"([^\W_]+)-\r?\n([^\W_]+)")

# token runs, the same character class the search layer extracts
_TOKEN = re.compile(r"[^\W_]+")


def fold_ligatures(text: str) -> str:
    """Every ligature presentation form -> its plain spelling."""
    for form, plain in LIGATURES.items():
        text = text.replace(form, plain)
    return text


def join_hyphenation(text: str, vocabulary: set[str]) -> tuple[str, int]:
    """Join end-of-line hyphenation splits, EVIDENCE-GATED.

    A ``word-``/newline/``continuation`` split joins into one word
    only when the joined form already exists in *vocabulary* (the
    corpus's own case-folded token set): the corpus proves the
    spelling before it is written.  A line-broken compound whose
    joined form is not a word (``Monte-``/``Carlo``) keeps its split —
    its tokenization already equals the unbroken compound's.  Returns
    the text and the number of joins made.
    """
    joins = 0

    def _join(m: re.Match[str]) -> str:
        nonlocal joins
        if (m.group(1) + m.group(2)).casefold() in vocabulary:
            joins += 1
            return m.group(1) + m.group(2)
        return m.group(0)

    return _HYPHEN_SPLIT.sub(_join, text), joins


@dataclass(frozen=True)
class NormalizeStats:
    """The build report's record: what the pass changed."""

    ligature_chunks: int = 0
    hyphen_joins: int = 0
    hyphen_joined_chunks: int = 0


def normalize_chunks(chunks: list[store.Chunk]
                     ) -> tuple[list[store.Chunk], NormalizeStats]:
    """The pass over every chunk: fold, then evidence-gated join.

    The vocabulary is computed from the LIGATURE-FOLDED texts of ALL
    chunks first (case-folded — the search layer's token equality),
    so a joined form is proven against exactly the tokens the index
    will hold.  Pure function of the input texts: same chunks in,
    same chunks out, every time.
    """
    folded = [fold_ligatures(c.text) for c in chunks]
    vocabulary: set[str] = set()
    for text in folded:
        for token in _TOKEN.findall(text.casefold()):
            vocabulary.add(token)

    ligature_chunks = 0
    hyphen_joins = 0
    hyphen_joined_chunks = 0
    out: list[store.Chunk] = []
    for chunk, text in zip(chunks, folded):
        changed = text != chunk.text
        if changed:
            ligature_chunks += 1
        joined_text, joins = join_hyphenation(text, vocabulary)
        if joins:
            hyphen_joins += joins
            hyphen_joined_chunks += 1
            changed = True
        out.append(store.Chunk(chunk_id=chunk.chunk_id, source=chunk.source,
                               cluster=chunk.cluster,
                               section=chunk.section, page=chunk.page,
                               text=joined_text if changed else chunk.text))
    stats = NormalizeStats(ligature_chunks=ligature_chunks,
                           hyphen_joins=hyphen_joins,
                           hyphen_joined_chunks=hyphen_joined_chunks)
    return out, stats
