"""Corpus extraction PDFs, TeX, RST/LOG/HTML).

``extract_pdf`` turns one PDF into citation-ready chunks: per page,
pypdf text is split into paragraphs and each paragraph becomes a chunk
carrying page-level provenance.  PDFs have no section structure worth
guessing at, so ``section`` is None for this extractor fills
it for TeX from the real heading tree).

Paragraph model: pypdf joins text lines with ``\\n`` and renders
inter-paragraph gaps as whitespace-only lines (measured on the real
corpus: ``"...2017 \\n \\nThis is..."``), so a paragraph is a maximal
run of non-blank lines.  Extraction is whole-file: any page raising
means pypdf is not viable for the source and NO chunks are returned
(partial extractability is not viability — same rule the probe
applies when classifying text_status).

``extract_tex``: EIRENE manual + solps.tex) splits on the
\\chapter/\\section/\\subsection tree, strips macros, and flattens math
to readable text.  The section carried by every chunk is the " > "
joined path from chapter down to subsection, so a citation names the
exact manual section ("answers cite the exact manual section").
Heading shapes verified on the real sources (2026-09-24): titles span
lines (chap1.tex:57), may carry \\label after the brace (chap1.tex:831),
starred forms exist (foreword.tex:1 ``\\section*``), and solps.tex has
``\\newpage\\subsection`` glue (solps.tex:927) plus macro names inside
titles (``\\SOLPSITER``, solps.tex:691).  verbatim/lstlisting blocks
are kept RAW (chap2b*.tex are EIRENE input-deck references — the deck
text is the content) and shielded from comment stripping and macro
flattening.  Everything before ``\\begin{document}`` is dropped: the
masters' preambles are typesetting configuration, not manual content
(eirene.tex and solps.tex both carry the marker).
"""

from __future__ import annotations

import contextlib
import html.parser
import logging
import re
import warnings
from pathlib import Path

from askthedocs import store
from askthedocs.store import Chunk


class ExtractionError(Exception):
    """The extractor could not read the whole source."""


@contextlib.contextmanager
def _silenced_pypdf():
    """pypdf emits dictionary-redefinition warning spam on some files."""
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        logging.getLogger("pypdf").setLevel(logging.ERROR)
        yield


def paragraphs(text: str) -> list[str]:
    """Split page text into paragraphs (maximal runs of non-blank lines).

    Line-internal structure is preserved (joined with ``\\n``) so chunk
    text stays faithful to the source layout; leading/trailing blank
    lines and blank-only runs produce no paragraphs.
    """
    paras: list[str] = []
    current: list[str] = []
    for line in text.splitlines():
        if line.strip():
            current.append(line.rstrip())
        elif current:
            paras.append("\n".join(current))
            current = []
    if current:
        paras.append("\n".join(current))
    return paras


def extract_pdf_pages(path: Path,
                      on_page=None) -> tuple[list[tuple[int, str]],
                                             int | None, int, str | None]:
    """Extract every page's text once: -> (page texts, pages, chars,
    error), the SAME numbers the richness classification records.

    *on_page*, when given, is called as (page number, total pages)
    AFTER each page's text is out (a page counts when it is
    finished, not when it starts - the display bar must never claim
    work that is still running).

    An error on ANY page marks the whole file (the pre-merge probe
    semantics): partial page texts still return, callers classify
    and skip, never chunk a failed file.
    """
    from pypdf import PdfReader

    with _silenced_pypdf():
        try:
            reader = PdfReader(str(path))
            page_objects = list(reader.pages)
        except Exception as exc:
            return [], None, 0, f"{type(exc).__name__}: {exc}"[:200]
        texts: list[tuple[int, str]] = []
        chars = 0
        for number, page in enumerate(page_objects, start=1):
            try:
                text = page.extract_text() or ""
            except Exception as exc:
                return texts, len(page_objects), chars, \
                    f"{type(exc).__name__}: {exc}"[:200]
            texts.append((number, text))
            chars += len(text)
            if on_page is not None:
                on_page(number, len(page_objects))
    return texts, len(page_objects), chars, None


def pdf_chunks_from_pages(repo: str, rel: str, cluster: str,
                          page_texts: list[tuple[int, str]]) -> list[Chunk]:
    """Chunks from already-extracted page texts (the same paragraph
    walk extract_pdf performs; byte-identical by construction)."""
    source = f"{repo}/{rel}"
    chunks: list[Chunk] = []
    for number, text in page_texts:
        for para_index, para in enumerate(paragraphs(text)):
            chunks.append(Chunk(
                chunk_id=store.make_chunk_id(source, number, para_index),
                source=source,
                cluster=cluster,
                section=None,
                page=number,
                text=para,
            ))
    return chunks


def extract_pdf(repo: str, rel: str, path: Path, cluster: str,
                on_page=None) -> list[Chunk]:
    """Extract one text-rich PDF into chunks (page + para provenance).

    *on_page*, when given, is called once per extracted page: the
    indexing display's per-document bar ticks from it.

    Raises ExtractionError if any page fails — callers report the
    source as failed rather than storing partial text.
    """
    from pypdf import PdfReader

    source = f"{repo}/{rel}"
    chunks: list[Chunk] = []
    with _silenced_pypdf():
        try:
            reader = PdfReader(str(path))
            pages = list(reader.pages)
        except Exception as exc:
            raise ExtractionError(
                f"{type(exc).__name__}: {exc}") from exc
        extracted: list[tuple[int, list[str]]] = []
        for number, page in enumerate(pages, start=1):
            try:
                text = page.extract_text() or ""
            except Exception as exc:
                raise ExtractionError(
                    f"page {number}: {type(exc).__name__}: {exc}") from exc
            extracted.append((number, text))
            if on_page is not None:
                on_page()

    return pdf_chunks_from_pages(repo, rel, cluster, extracted)


# --- : structured TeX extraction (EIRENE manual + solps.tex) ---

# heading levels -> depth in the section path (chapter/section/subsection,
# plus subsubsection for : amjuel.tex organises the fit types
# H.0..H.17 as \subsubsection and "cite the exact section" needs them)
HEADING_LEVELS = {"chapter": 0, "section": 1, "subsection": 2,
                  "subsubsection": 3}
# titles may be starred (\section*) and/or carry a [short-title] arg
HEADING_RE = re.compile(
    r"\\(chapter|subsubsection|subsection|section)\*?\s*(?:\[[^\]\n]*\]\s*)?\{")
# verbatim-family environments: content kept raw, shielded from cleaning.
# AMdata tables open as \begin{small}\begin{verbatim} (1,438 measured
# occurrences, the only wrapper shape in the corpus); the size wrapper
# is allowed before the verbatim begin so the tables reach the raw
# path instead of being macro-flattened.
VERBATIM_ENVS = frozenset({"verbatim", "Verbatim", "lstlisting", "listing"})
VERBATIM_BEGIN_RE = re.compile(
    r"^\s*(?:\\begin\{small\}\s*)?\\begin\{("
    + "|".join(sorted(VERBATIM_ENVS)) + r")\}"
    r"(?:\[[^\]]*\])?\s*$")

# non-verbatim environment wrappers: dropped, content flows on as text
_ENV_WRAPPER_RE = re.compile(r"\\(?:begin|end)\{[^{}]*\}")

# macros dropped TOGETHER WITH their argument (metadata / layout noise;
#\index alone accounts for 3,916 occurrences in the scope)
DROP_ARG_MACROS = (
    "index", "label", "cite", "ref", "cref", "Cref", "eqref", "autoref",
    "pageref", "vref", "include", "input", "bibliography", "bibliographystyle",
    "includegraphics", "vspace", "hspace", "pagestyle", "thispagestyle",
    "setcounter", "addtocounter", "graphicspath", "addbibresource",
    "printbibliography", "tableofcontents",
)
_DROP_ARG_RE = re.compile(
    r"\\(?:" + "|".join(DROP_ARG_MACROS) + r")"
    r"(?:\[[^\]]*\])?\{[^{}]*\}")

# argumentless macros whose NAMES are pure layout noise (\tt: 5,477 uses)
DROP_NAME_MACROS = frozenset({
    "tt", "bf", "it", "rm", "sf", "sc", "em", "sl",
    "Huge", "huge", "Large", "LARGE", "large", "small", "footnotesize",
    "scriptsize", "tiny", "normalsize",
    "medskip", "bigskip", "smallskip", "noindent", "newline", "newpage",
    "clearpage", "centering", "raggedright", "raggedleft",
    "hline", "hdashline", "left", "right", "displaystyle", "limits",
    "nonumber", "notag", "hfill", "vfill", "strut", "quad", "qquad",
    "mid", "big", "Big", "bigg", "Bigg", "today", "pagenumbering",
    "lstinline", "verb", "par", "indent",
})
# macros unwrapped to their FIRST braced argument (formatting wrappers,
# acronyms, units; \texorpdfstring keeps the TeX-side title)
UNWRAP_MACROS = (
    "textbf", "textit", "texttt", "emph", "underline", "textrm", "textsf",
    "textsc", "text", "mathrm", "mathbf", "mathit", "mathsf", "mathtt",
    "mbox", "ensuremath", "ac", "acs", "acl", "acf", "acp", "si", "SI",
    "caption", "footnote", "ordinalnum", "url", "texorpdfstring",
    "textsuperscript", "textsubscript",
)
_UNWRAP_RE = re.compile(
    r"\\(?:" + "|".join(UNWRAP_MACROS) + r")\s*\{([^{}]*)\}")
# accent constructs (J\"ulich etc.): accent mark dropped, letter kept
_ACCENT_RE = re.compile(r"\\['`\"^~=.]\s*")
_MACRO_RE = re.compile(r"\\([a-zA-Z]+)")

# display-math delimiters (inline $ handled with the other unescapes)
_DISPLAY_MATH_RE = re.compile(r"\\\[|\\\]")

_ESCAPES = {r"\%": "%", r"\&": "&", r"\_": "_", r"\#": "#",
            r"\{": "", r"\}": ""}


def strip_comments(line: str) -> str:
    """Cut an unescaped ``%`` and everything after it (verbatim excluded)."""
    cut = len(line)
    i = 0
    while i < len(line):
        if line[i] == "\\":
            i += 2  # escaped char (\% \& ...) — never a comment start
            continue
        if line[i] == "%":
            cut = i
            break
        i += 1
    return line[:cut]


def clean_tex(text: str) -> str:
    """Flatten TeX body text to readable plain text.

    Macros with a braced argument are unwrapped (their argument text
    survives) except the DROP_ARG metadata macros, which vanish with
    their argument; argumentless macro names survive as words except
    the layout-noise list; math delimiters, braces, and ``~`` vanish.
    Unknown constructs degrade to their name/text — readable text, not
    semantic math rendering, is the contract.
    """
    for _ in range(10):  # loop: successive args (\cite{a}\cite{b})
        stripped = _DROP_ARG_RE.sub(" ", text)
        if stripped == text:
            break
        text = stripped
    for _ in range(10):  # loop: nested wrappers (\textbf{\textit{x}})
        stripped = _UNWRAP_RE.sub(r" \1 ", text)
        if stripped == text:
            break
        text = stripped
    text = _ACCENT_RE.sub("", text)        # J\"ulich -> Julich
    text = text.replace("\\\\", "\n\n")     # table rows / hard breaks
    text = text.replace("\\item", "\n\n")   # items are logical paragraphs
    text = _DISPLAY_MATH_RE.sub(" ", text)
    text = _ENV_WRAPPER_RE.sub(" ", text)   # \begin{...}/\end{...} wrappers

    def _demacro(match: re.Match[str]) -> str:
        return "" if match.group(1) in DROP_NAME_MACROS else f" {match.group(1)} "

    text = _MACRO_RE.sub(_demacro, text)
    text = text.replace("\\$", " ")         # escaped currency, not a delim
    text = text.replace("$", " ")           # inline math delimiters
    for escaped, plain in _ESCAPES.items():
        text = text.replace(escaped, plain)
    text = text.replace("{", " ").replace("}", " ")
    text = text.replace("~", " ")
    # collapse runs of blanks, keep line structure
    lines = [re.sub(r"[ \t]+", " ", ln).strip() for ln in text.splitlines()]
    return "\n".join(lines)


def _read_braced(text: str, open_index: int) -> tuple[str, int]:
    """Title between the brace at *open_index* and its match (titles span
    lines); returns (title_source, index_after_close_brace).

    A backslash escapes the NEXT character (skipped in pairs) — a
    doubled backslash (TeX line break ``\\\\``) is two escaped units,
    so the brace after it is NOT escaped.  Skipping single characters
    after each backslash, rather than testing the previous one, is
    what keeps ``\\\\}`` closing correctly."""
    depth = 0
    i = open_index
    n = len(text)
    while i < n:
        char = text[i]
        if char == "\\":
            i += 2  # escaped char inside the title
            continue
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[open_index + 1:i], i + 1
        i += 1
    raise ExtractionError("unbalanced braces in heading title")


def tex_segments(body: str) -> list[tuple[str | None, str]]:
    """Split TeX body into (section_path, text) segments.

    section_path is the " > " joined chapter/section/subsection chain;
    content before the first heading lands under a None path.
    """
    segments: list[tuple[str | None, str]] = []
    stack: list[tuple[int, str]] = []  # (level, cleaned title)
    start = 0
    pos = 0
    while (match := HEADING_RE.search(body, pos)) is not None:
        title_source, after = _read_braced(body, match.end() - 1)
        segments.append((_section_path(stack), body[start:match.start()]))
        level = HEADING_LEVELS[match.group(1)]
        stack = [(l, t) for l, t in stack if l < level]
        stack.append((level, re.sub(r"\s+", " ", clean_tex(title_source)).strip()))
        start = after
        pos = after
    segments.append((_section_path(stack), body[start:]))
    return [(path, text) for path, text in segments if text.strip()]


def _section_path(stack: list[tuple[int, str]]) -> str | None:
    return " > ".join(title for _, title in stack) if stack else None


# NUL can never occur in the utf-8 source text — safe sentinel pattern
_SENTINEL_RE = re.compile("\x00(\\d+)\x00")

# a data-table row: one short label run (spaces allowed, <=16 chars),
# then either nothing (bare header, "T-Index:", "T Index") or an
# optional "=" and a numeric-leading value run.  Measured on the
# AMdata verbatim tables (2026-09-24): "p0  2.280000000000D+00 ..."
#(amjuel.tex), "a0 -4.99e+02 ..." (hydhel.tex), "Emin  1.08e+01
# s(Emin)  1.00e-19" (hydhel.tex:573), "fit-flag 02" (amjuel.tex:608
# block), "ELABMIN=   1.82060E 00 eV" / "N2MIN =   1.00000D 08
#1/CM3" (glued/spaced equals), "Mean rel. Error:    .0000 %"
#(h2vibr.tex), "E Index    0    1 ..." / "E-Index:  0 ..." plus
# bare "T-Index:" and matrix rows "   0  -1.82D+01 ..." (amjuel
# double-polynomial fits).  The 16-char label cap plus the trailing $
# keep prose and listings out: "Error is improved to 2.24e-03 (C)
# if ..." (h2vibr.tex, 20-char label) fails, as do "C    FILNAM:
# read a&m data ..." and "      SUBROUTINE SLREAC (IR, ...)" —
# those blocks keep whole-block paragraph splitting.
_ROW_RE = re.compile(
    r"\s*[\w.()/+=: -]{1,16}(?:\s*=?\s*[-+.0-9].*)?$")
# widest measured data row fits a punch-card-ish 120 columns; longer
# lines are prose/listings, not coefficient rows
_ROW_MAX_WIDTH = 120


def table_rows(block: str) -> list[str] | None:
    """Per-row texts for a verbatim block that is a data table).

    A block is a data table when EVERY non-blank line is a row (label
    token + numeric-leading values, at most 120 columns).  Then each
    non-blank line becomes its own chunk text, rstripped only — the row
    text is preserved byte-faithfully, leading indentation included.
    Returns None for anything else (code listings, mixed prose): the
    caller falls back to blank-line paragraph splitting.
    """
    rows = [line.rstrip() for line in block.splitlines() if line.strip()]
    if len(rows) < 2 or any(
            len(line) > _ROW_MAX_WIDTH or not _ROW_RE.match(line)
            for line in rows):
        return None
    return rows


def _read_body(path: Path) -> tuple[str, list[str]]:
    """Comment-strip the document body; keep verbatim blocks raw.

    Everything before \\begin{document} (typesetting preamble) is
    dropped.  Verbatim-family environments are lifted out and replaced
    by ``\\x00n\\x00`` sentinels (returned alongside) so the cleaning
    pass can never touch deck text — only blank-line paragraph
    splitting applies to them.
    """
    try:
        raw = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        raise ExtractionError(f"not utf-8: {exc}") from exc
    lines: list[str] = []
    raw_blocks: list[str] = []
    block: list[str] | None = None
    end_re: re.Pattern[str] | None = None
    in_document = "\\begin{document}" not in raw
    for line in raw.splitlines():
        if not in_document:
            if "\\begin{document}" in line:
                in_document = True
            continue
        if block is not None:
            if end_re is not None and end_re.search(line):
                raw_blocks.append("\n".join(block))
                lines.append(f"\x00{len(raw_blocks) - 1}\x00")
                block = None
                end_re = None
            else:
                block.append(line)
            continue
        begin = VERBATIM_BEGIN_RE.search(line)
        if begin is not None:
            env = begin.group(1)
            block = []
            end_re = re.compile(r"\\end\{" + env + r"\}")
            continue
        lines.append(strip_comments(line))
    return "\n".join(lines), raw_blocks


def extract_tex(repo: str, rel: str, path: Path, cluster: str) -> list[Chunk]:
    """Extract one structured TeX source into sectioned chunks).

    page is None (TeX carries section provenance instead); the chunk-ID
    para-index is a per-file running counter, so IDs are unique and
    rebuild-stable by construction.  Verbatim blocks become their own
    chunks, byte-faithful to the source: data tables split one chunk
    per row), listings split on blank lines).
    """
    source = f"{repo}/{rel}"
    body, raw_blocks = _read_body(path)
    chunks: list[Chunk] = []
    counter = 0
    for section, text in tex_segments(body):
        pieces = _SENTINEL_RE.split(text)
        # even indices: cleanable text; odd: index into raw_blocks
        for index, piece in enumerate(pieces):
            if index % 2:  # raw block: no macro flattening, ever
                raw = raw_blocks[int(piece)]
                # data tables: one chunk per row); listings keep
                # blank-line paragraphs
                paras = table_rows(raw) or paragraphs(raw)
            else:
                paras = paragraphs(clean_tex(piece))
            for para in paras:
                chunks.append(Chunk(
                    chunk_id=store.make_chunk_id(source, None, counter),
                    source=source,
                    cluster=cluster,
                    section=section,
                    page=None,
                    text=para,
                ))
                counter += 1
    return chunks


# --- : RST, LOG, HTML extraction ---

# docutils allows any punctuation run as a section adornment; measured
# in the GUI corpus (32 files, 2026-09-24): - = ~ ^ ' * . # (underline-
# only and overline+underline forms).  Levels are assigned per FILE by
# first appearance of the character, which is docutils' own rule —
# b2input.rst opens with overlined `*` sections while gui/index.rst
# opens with overlined `=`.
RST_ADORNMENT_CHARS = frozenset("!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")

# directives whose whole indented block is navigation/config noise and
# is dropped (measured counts: image 296, index 1062 — mostly
# line-form `.. index:: term`, block-form carries `single: X; Y`
# term lists — automodule 19, toctree 5, only 4, role 1).
# figure/note/tip/table/seealso/topic/math (434 combined) keep their
# blocks — captions and notes are real content; only the directive
# line itself and `:option:` lines vanish.
RST_BLOCK_DROP_DIRECTIVES = frozenset(
    {"toctree", "image", "automodule", "only", "role", "index"})

_RST_DIRECTIVE_RE = re.compile(r"^(\s*)\.\.\s+([A-Za-z][\w+-]*)::?")
# label targets (`.. _fig-runs-8:`) and `:option:` lines (`:alt:`,
#`:maxdepth:`) carry no prose
_RST_LABEL_RE = re.compile(r"^\s*\.\. _")
_RST_OPTION_RE = re.compile(r"^\s*:[\w -]+:")

# interpreted-text roles keep their argument (`:ref:`X <url>`` -> X)
_RST_ROLE_RE = re.compile(r":[\w+-]+:`([^`<>]+)(?:\s+<[^>]*>)?`")
_RST_LITERAL_RE = re.compile(r"``([^`]+)``")
_RST_LINK_RE = re.compile(r"`([^`<>]+)(?:\s+<[^>]*>)?`_")
_RST_STRONG_RE = re.compile(r"\*\*([^*]+)\*\*")
_RST_EMPHASIS_RE = re.compile(r"(?<![\w*])\*([^*\n]+)\*(?![\w*])")


def _adornment(line: str) -> tuple[str, int] | None:
    """(char, length) when the line is a run of one punctuation char."""
    stripped = line.strip()
    if not stripped or len(set(stripped)) != 1:
        return None
    char = stripped[0]
    return (char, len(stripped)) if char in RST_ADORNMENT_CHARS else None


def rst_segments(text: str) -> list[tuple[str | None, str]]:
    """Split reST into (section_path, text) segments).

    A heading is a title line plus an underline at least as long, or
    the overlined form (adornment / title / adornment, both >= title).
    Titles must contain a non-adornment character (a bare rule between
    blanks is a transition, not a heading) and must not open with the
    directive marker.  Depth of a heading = first-appearance order of
    its (adornment char, overlined?) style within the file — docutils'
    own rule, where an overlined `=` document title and underline `=`
    sections are DIFFERENT levels; without the overline distinction,
    16 of the 32 GUI files would lose their title from every section
    path (measured 2026-09-24).  The section path is the " > " joined
    chain, as for TeX.
    """
    lines = text.splitlines()
    levels: dict[tuple[str, bool], int] = {}
    segments: list[tuple[str | None, str]] = []
    stack: list[tuple[int, str]] = []
    start = 0
    i = 0
    while i < len(lines):
        title: str | None = None
        style: tuple[str, bool] | None = None
        after = i
        over = _adornment(lines[i])
        if over is not None and over[1] >= 2 and i + 2 < len(lines):
            # overlined form: rule / title / rule, same char, both rules
            # at least as wide as the title, title not a rule itself
            under = _adornment(lines[i + 2])
            width = len(lines[i + 1].strip())
            if (under is not None and under[0] == over[0]
                    and _adornment(lines[i + 1]) is None
                    and 0 < width <= over[1] and width <= under[1]):
                title, style, after = (lines[i + 1].strip(),
                                       (over[0], True), i + 3)
        if title is None and i + 1 < len(lines):
            under = _adornment(lines[i + 1])
            stripped = lines[i].strip()
            if (under is not None and under[1] >= 2 and stripped
                    and _adornment(lines[i]) is None
                    and not stripped.startswith("..")
                    and len(stripped) <= under[1]):
                title, style, after = stripped, (under[0], False), i + 2
        if title is not None and style is not None:
            segments.append((_section_path(stack),
                             "\n".join(lines[start:i])))
            level = levels.setdefault(style, len(levels))
            stack = [(l, t) for l, t in stack if l < level]
            stack.append((level, title))
            start = after
            i = after
            continue
        i += 1
    segments.append((_section_path(stack), "\n".join(lines[start:])))
    return [(path, text) for path, text in segments if text.strip()]


def clean_rst(text: str) -> str:
    """Strip reST markup noise to readable plain text).

    Dropped: label targets, `:option:` lines, and the pinned navigation
    directives WITH their indented blocks (toctree/image/automodule/
    only/role).  Every other directive loses only its `.. name::` line
    — the note/figure/tip content flows on as prose.  Inline: roles,
    double-backtick literals, `hyperlink`_ targets, **strong** and
    *emphasis* keep their inner text only.
    """
    out: list[str] = []
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if _RST_LABEL_RE.match(line) or _RST_OPTION_RE.match(line):
            i += 1
            continue
        directive = _RST_DIRECTIVE_RE.match(line)
        if directive is not None:
            name = directive.group(2).lower()
            indent = len(directive.group(1))
            i += 1
            if name in RST_BLOCK_DROP_DIRECTIVES:
                while i < len(lines):
                    nxt = lines[i]
                    if nxt.strip() and len(nxt) - len(nxt.lstrip()) <= indent:
                        break
                    i += 1
            continue
        out.append(line)
        i += 1
    text = "\n".join(out)
    for _ in range(4):  # loop: ``a`` and **b** can abut
        swapped = _RST_ROLE_RE.sub(r"\1", text)
        swapped = _RST_LITERAL_RE.sub(r"\1", swapped)
        swapped = _RST_LINK_RE.sub(r"\1", swapped)
        swapped = _RST_STRONG_RE.sub(r"\1", swapped)
        swapped = _RST_EMPHASIS_RE.sub(r"\1", swapped)
        if swapped == text:
            break
        text = swapped
    return text


def extract_rst(repo: str, rel: str, path: Path, cluster: str) -> list[Chunk]:
    """Extract one reST source into sectioned chunks).

    page is None (section provenance instead); the chunk-ID para-index
    is a per-file running counter, so IDs are unique and rebuild-stable
    by construction (same contract as extract_tex).
    """
    source = f"{repo}/{rel}"
    try:
        raw = path.read_text(encoding="utf-8")  # all 32 files decode (measured)
    except UnicodeDecodeError as exc:
        raise ExtractionError(f"not utf-8: {exc}") from exc
    chunks: list[Chunk] = []
    counter = 0
    for section, text in rst_segments(raw):
        for para in paragraphs(clean_rst(text)):
            chunks.append(Chunk(
                chunk_id=store.make_chunk_id(source, None, counter),
                source=source,
                cluster=cluster,
                section=section,
                page=None,
                text=para,
            ))
            counter += 1
    return chunks


# Markdown grammar (measured 2026-10-18 on the SOLPS-Tutorials
# clone, 25 .md sources): ATX headings only (no setext, no front
# matter), MkDocs-relative links, inline HTML limited to the
# material-symbols "open_in_new" decoration spans, one mkdocs-macros
#{{ }} occurrence (kept verbatim).
_MD_ATX_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*#*\s*$")
_MD_IMAGE_RE = re.compile(r"!\[([^\]]*)\]\([^)]*\)")
_MD_LINK_RE = re.compile(r"\[([^\]]+)\]\([^)]*\)")
_MD_HTML_RE = re.compile(r"<[^>]+>")
_MD_CODE_RE = re.compile(r"`([^`]*)`")
_MD_BOLD_RE = re.compile(r"\*\*([^*]+)\*\*|__([^_]+)__")
_MD_ITAL_RE = re.compile(r"\*([^*]+)\*|(?<!\w)_([^_]+)_(?!\w)")
_MD_FENCE_RE = re.compile(r"^(```|~~~)")


def md_segments(text: str) -> list[tuple[str | None, str]]:
    """Split Markdown into (section_path, text) segments.

    ATX headings only (measured grammar above); depth = the # count,
    and the section path is the " > " joined chain, as for TeX/reST.
    """
    lines = text.splitlines()
    segments: list[tuple[str | None, str]] = []
    stack: list[tuple[int, str]] = []
    start = 0
    i = 0
    while i < len(lines):
        m = _MD_ATX_RE.match(lines[i])
        if m is not None:
            segments.append((_section_path(stack),
                             "\n".join(lines[start:i])))
            level = len(m.group(1))
            title = m.group(2).strip()
            stack = [(l, t) for l, t in stack if l < level]
            stack.append((level, title))
            start = i + 1
            i += 1
            continue
        i += 1
    segments.append((_section_path(stack), "\n".join(lines[start:])))
    return [(path, seg) for path, seg in segments if seg.strip()]


def clean_md(text: str) -> str:
    """Strip Markdown markup to readable plain text.

    Dropped: HTML decoration spans (the material-icons glue), fence
    markers, blockquote ticks.  Kept as inner text: images (alt),
    links, bold/italic markers, inline code.  Same contract as
    clean_rst — prose survives, glue does not.
    """
    out = []
    for line in text.splitlines():
        if _MD_FENCE_RE.match(line):
            continue
        line = _MD_IMAGE_RE.sub(r"\1", line)
        line = _MD_LINK_RE.sub(r"\1", line)
        line = _MD_HTML_RE.sub("", line)
        line = _MD_CODE_RE.sub(r"\1", line)
        line = _MD_BOLD_RE.sub(lambda m: m.group(1) or m.group(2), line)
        line = _MD_ITAL_RE.sub(lambda m: m.group(1) or m.group(2), line)
        line = re.sub(r"^\s*>\s?", "", line)
        out.append(line)
    return "\n".join(out)


def extract_md(repo: str, rel: str, path: Path, cluster: str) -> list[Chunk]:
    """Extract one Markdown source into sectioned chunks.

    Same contract as extract_rst: page is None (section provenance
    instead); the chunk-ID para-index is a per-file running counter,
    so IDs are unique and rebuild-stable by construction.
    """
    source = f"{repo}/{rel}"
    try:
        raw = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        raise ExtractionError(f"not utf-8: {exc}") from exc
    chunks: list[Chunk] = []
    counter = 0
    for section, text in md_segments(raw):
        for para in paragraphs(clean_md(text)):
            chunks.append(Chunk(
                chunk_id=store.make_chunk_id(source, None, counter),
                source=source,
                cluster=cluster,
                section=section,
                page=None,
                text=para,
            ))
            counter += 1
    return chunks


# doc/LOG grammar (measured 2026-09-24): 104 dated entries, each a
# header line `YYYY.MM.<rest>` underlined by `=`s, separated by a run
# of exactly 79 `o`s.  Five headers deviate from plain YYYY.MM.dd —
#2007.01.dd, 2006.02.yy, 2002.11.28/29, 2002.08.16--23,
#2002.04.10+11 — and are kept verbatim as section values.  The
# underline requirement rejects the two prose lines that merely START
# with a date ("2004.07.20) to ...", "2004.06.19 entry ...").
_LOG_HEADER_RE = re.compile(r"^\d{4}\.\d{2}\.\S*$")
_LOG_UNDERLINE_RE = re.compile(r"^=+$")
_LOG_SEPARATOR_RE = re.compile(r"^o{10,}$")


def log_entries(text: str) -> list[tuple[str, str]]:
    """(date, body) for every dated entry, file order (newest first).

    The body runs from below the header's underline to the next header,
    with trailing `o`-run separators and blank tail removed; internal
    sub-headers (`old eirene:` etc.) are part of the entry text.
    """
    lines = [line.rstrip() for line in text.splitlines()]
    heads = [(i, lines[i].strip()) for i in range(len(lines) - 1)
             if _LOG_HEADER_RE.match(lines[i])
             and _LOG_UNDERLINE_RE.match(lines[i + 1])]
    entries: list[tuple[str, str]] = []
    starts = [i + 2 for i, _ in heads]
    ends = [i for i, _ in heads[1:]] + [len(lines)]
    for (_, date), start_line, end_line in zip(heads, starts, ends):
        # separator runs are structural: 79-'o' rules separate entries
        # (and, in two 2002 entries, internal subsections)
        body = [line for line in lines[start_line:end_line]
                if not _LOG_SEPARATOR_RE.match(line)]
        while body and not body[-1].strip():
            body.pop()
        while body and not body[0].strip():
            body.pop(0)
        if body:
            entries.append((date, "\n".join(body)))
    preamble = lines[:heads[0][0]] if heads else lines
    while preamble and not preamble[-1].strip():
        preamble.pop()
    if heads and any(line.strip() for line in preamble):
        entries.insert(0, ("", "\n".join(preamble)))  # none measured
    return entries


def extract_log(repo: str, rel: str, path: Path, cluster: str) -> list[Chunk]:
    """doc/LOG: each dated entry = ONE chunk, section = the date string
 — the citation lands on the changelog day itself."""
    source = f"{repo}/{rel}"
    try:
        raw = path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        raise ExtractionError(f"not utf-8: {exc}") from exc
    return [
        Chunk(
            chunk_id=store.make_chunk_id(source, None, index),
            source=source,
            cluster=cluster,
            section=date or None,
            page=None,
            text=body,
        )
        for index, (date, body) in enumerate(log_entries(raw))
    ]


class _WordHTMLParser(html.parser.HTMLParser):
    """Collect paragraph texts from a Word-97 HTML export.

    Measured shape (dg_manual_1.20.htm): 446 ``<P>`` opens but only 370
    ``</P>`` closes — a new ``<P>`` implicitly closes the open one;
    8 ``<TD>`` cells hold bare text with no paragraph around it (the
    other 76 wrap one), so cells flush only their own unwrapped text;
    ``&nbsp;`` spacers unescape to U+00A0, which ``str.split()`` and
    ``\\s`` both treat as whitespace, so blank paragraphs vanish.
    """

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.paragraphs: list[str] = []
        self._p: list[str] | None = None
        self._td: list[str] | None = None
        self._head = False

    def _flush(self) -> None:
        if self._p is not None:
            text = re.sub(r"\s+", " ", "".join(self._p)).strip()
            if text:
                self.paragraphs.append(text)
        self._p = None

    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if tag == "head":
            self._head = True
        elif tag == "p":
            self._flush()  # unclosed <P>: a new one closes it
            self._p = []
        elif tag == "td" and self._td is None:
            self._td = [] if self._p is None else None

    def handle_endtag(self, tag):
        tag = tag.lower()
        if tag == "head":
            self._head = False
        elif tag == "p":
            self._flush()
        elif tag == "td" and self._td is not None:
            text = re.sub(r"\s+", " ", "".join(self._td)).strip()
            if text:
                self.paragraphs.append(text)
            self._td = None

    def handle_data(self, data):
        if self._head:
            return
        if self._p is not None:
            self._p.append(data)
        elif self._td is not None:
            self._td.append(data)


def extract_htm(repo: str, rel: str, path: Path, cluster: str) -> list[Chunk]:
    """Extract the DivGeo HTML manual into text chunks).

    The source declares ``charset=windows-1252`` and does NOT decode as
    utf-8 (measured) — utf-8 is tried first, cp1252 is the fallback.
    The scope limits this to "text chunks": section stays None (the
    Word export styles its numbered titles as plain paragraphs, which
    remain their own findable chunks).
    """
    source = f"{repo}/{rel}"
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        try:
            text = raw.decode("cp1252")
        except UnicodeDecodeError as exc:
            raise ExtractionError(f"not utf-8/cp1252: {exc}") from exc
    parser = _WordHTMLParser()
    parser.feed(text)
    parser.close()
    return [
        Chunk(
            chunk_id=store.make_chunk_id(source, None, index),
            source=source,
            cluster=cluster,
            section=None,
            page=None,
            text=para,
        )
        for index, para in enumerate(parser.paragraphs)
    ]
