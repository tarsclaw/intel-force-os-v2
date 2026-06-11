// Minimal YAML-subset parser + emitter — zero npm deps (bridge precedent:
// the package ships dependency-free; js-yaml is NOT added for two small,
// fully-specified vault files).
//
// Scope is exactly what the routing vault artefacts need
// (docs/specs/approval-routing-architecture.md §6.3 sample verbatim):
//   - block maps + block sequences via 2-space indentation
//   - "- key: value" inline-start map list items
//   - scalars: null/~, true/false, integers, floats, single/double-quoted
//     strings, plain strings
//   - inline empty collections: [] and {}
//   - full-line and trailing comments (# outside quotes)
//
// NOT supported (parse error or plain-string fallback, never silent
// misparse): anchors/aliases, multi-line block scalars (| >), flow
// sequences/maps with content, tabs for indentation. The loaders validate
// shape after parse, so an out-of-scope file fails loudly as a typed
// validation error — the caller falls back (PLAN.md decision 2).

export type YamlValue =
  | string
  | number
  | boolean
  | null
  | YamlValue[]
  | { [key: string]: YamlValue };

export class YamlParseError extends Error {
  readonly line: number;
  constructor(message: string, line: number) {
    super(`yaml-lite: ${message} (line ${line})`);
    this.name = "YamlParseError";
    this.line = line;
  }
}

interface Line {
  indent: number;
  text: string; // comment-stripped, rtrimmed, non-empty
  num: number; // 1-based source line number
}

/** Strips a trailing comment, respecting single/double quotes. */
function stripComment(raw: string): string {
  let inSingle = false;
  let inDouble = false;
  for (let i = 0; i < raw.length; i++) {
    const c = raw[i];
    if (c === "'" && !inDouble) inSingle = !inSingle;
    else if (c === '"' && !inSingle) inDouble = !inDouble;
    else if (c === "#" && !inSingle && !inDouble) {
      // YAML: '#' starts a comment at line start or after whitespace.
      if (i === 0 || raw[i - 1] === " " || raw[i - 1] === "\t") {
        return raw.slice(0, i);
      }
    }
  }
  return raw;
}

function toLines(source: string): Line[] {
  const out: Line[] = [];
  const rawLines = source.split("\n");
  for (let i = 0; i < rawLines.length; i++) {
    const raw = rawLines[i];
    if (raw.includes("\t")) {
      throw new YamlParseError("tabs are not supported for indentation", i + 1);
    }
    const stripped = stripComment(raw).replace(/\s+$/, "");
    if (stripped.trim() === "") continue;
    if (stripped.trim() === "---") continue; // document marker — single-doc files only
    const indent = stripped.length - stripped.trimStart().length;
    out.push({ indent, text: stripped.trim(), num: i + 1 });
  }
  return out;
}

function parseScalar(text: string, lineNum: number): YamlValue {
  const t = text.trim();
  if (t === "" || t === "~" || t === "null" || t === "Null" || t === "NULL") return null;
  if (t === "true" || t === "True") return true;
  if (t === "false" || t === "False") return false;
  if (t === "[]") return [];
  if (t === "{}") return {};
  if (/^-?\d+$/.test(t)) return Number.parseInt(t, 10);
  if (/^-?\d+\.\d+$/.test(t)) return Number.parseFloat(t);
  if (t.startsWith('"')) {
    if (!t.endsWith('"') || t.length < 2) {
      throw new YamlParseError(`unterminated double-quoted string`, lineNum);
    }
    return t.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, "\\");
  }
  if (t.startsWith("'")) {
    if (!t.endsWith("'") || t.length < 2) {
      throw new YamlParseError(`unterminated single-quoted string`, lineNum);
    }
    return t.slice(1, -1).replace(/''/g, "'");
  }
  if (t.startsWith("[") || t.startsWith("{") || t.startsWith("&") || t.startsWith("*") || t === "|" || t === ">") {
    throw new YamlParseError(`unsupported YAML construct: ${t.slice(0, 20)}`, lineNum);
  }
  return t; // plain string
}

/** Splits "key: value" / "key:" — returns null if the line is not a map entry. */
function splitKey(text: string): { key: string; rest: string } | null {
  // Key = up to the first ': ' or trailing ':' outside quotes.
  let inSingle = false;
  let inDouble = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (c === "'" && !inDouble) inSingle = !inSingle;
    else if (c === '"' && !inSingle) inDouble = !inDouble;
    else if (c === ":" && !inSingle && !inDouble) {
      if (i === text.length - 1 || text[i + 1] === " ") {
        const rawKey = text.slice(0, i).trim();
        const key = rawKey.startsWith('"') || rawKey.startsWith("'")
          ? (parseScalar(rawKey, 0) as string)
          : rawKey;
        return { key, rest: text.slice(i + 1).trim() };
      }
    }
  }
  return null;
}

class Parser {
  private readonly lines: Line[];
  private pos = 0;

  constructor(lines: Line[]) {
    this.lines = lines;
  }

  parse(): YamlValue {
    if (this.lines.length === 0) return {};
    const value = this.parseBlock(this.lines[0].indent);
    if (this.pos < this.lines.length) {
      throw new YamlParseError(
        `unexpected content after document`,
        this.lines[this.pos].num,
      );
    }
    return value;
  }

  private peek(): Line | null {
    return this.pos < this.lines.length ? this.lines[this.pos] : null;
  }

  private parseBlock(indent: number): YamlValue {
    const first = this.peek();
    if (!first) return null;
    if (first.text.startsWith("- ") || first.text === "-") {
      return this.parseSequence(indent);
    }
    return this.parseMap(indent);
  }

  private parseSequence(indent: number): YamlValue[] {
    const out: YamlValue[] = [];
    for (;;) {
      const line = this.peek();
      if (!line || line.indent !== indent) break;
      if (!(line.text.startsWith("- ") || line.text === "-")) break;
      this.pos++;
      const inner = line.text === "-" ? "" : line.text.slice(2).trim();
      // Item content is logically indented at indent+2 (the char after "- ").
      const itemIndent = indent + 2;
      if (inner === "") {
        const next = this.peek();
        if (next && next.indent >= itemIndent) {
          out.push(this.parseBlock(next.indent));
        } else {
          out.push(null);
        }
        continue;
      }
      const kv = splitKey(inner);
      if (kv) {
        // "- key: value" starts an inline map item; subsequent keys sit at itemIndent.
        out.push(this.parseInlineMapItem(kv, itemIndent, line.num));
      } else {
        out.push(parseScalar(inner, line.num));
      }
    }
    return out;
  }

  private parseInlineMapItem(
    firstKv: { key: string; rest: string },
    itemIndent: number,
    lineNum: number,
  ): YamlValue {
    const obj: { [key: string]: YamlValue } = {};
    this.assignEntry(obj, firstKv, itemIndent, lineNum);
    for (;;) {
      const line = this.peek();
      if (!line || line.indent !== itemIndent) break;
      if (line.text.startsWith("- ")) break;
      const kv = splitKey(line.text);
      if (!kv) throw new YamlParseError(`expected "key: value"`, line.num);
      this.pos++;
      this.assignEntry(obj, kv, itemIndent, line.num);
    }
    return obj;
  }

  private parseMap(indent: number): { [key: string]: YamlValue } {
    const obj: { [key: string]: YamlValue } = {};
    for (;;) {
      const line = this.peek();
      if (!line || line.indent !== indent) break;
      if (line.text.startsWith("- ")) {
        throw new YamlParseError(`unexpected sequence item in map`, line.num);
      }
      const kv = splitKey(line.text);
      if (!kv) throw new YamlParseError(`expected "key: value"`, line.num);
      this.pos++;
      this.assignEntry(obj, kv, indent, line.num);
    }
    return obj;
  }

  /** Assigns one "key: ..." entry, recursing into a nested block when value is empty. */
  private assignEntry(
    obj: { [key: string]: YamlValue },
    kv: { key: string; rest: string },
    indent: number,
    lineNum: number,
  ): void {
    if (Object.prototype.hasOwnProperty.call(obj, kv.key)) {
      throw new YamlParseError(`duplicate key "${kv.key}"`, lineNum);
    }
    if (kv.rest === "") {
      const next = this.peek();
      if (next && next.indent > indent) {
        obj[kv.key] = this.parseBlock(next.indent);
      } else {
        obj[kv.key] = null;
      }
    } else {
      obj[kv.key] = parseScalar(kv.rest, lineNum);
    }
  }
}

/** Parses a YAML-subset document. Throws YamlParseError on out-of-scope input. */
export function parseYaml(source: string): YamlValue {
  return new Parser(toLines(source)).parse();
}

// ── Emitter ────────────────────────────────────────────────────────────────

const PLAIN_STRING_RE = /^[A-Za-z0-9_][A-Za-z0-9_\-./@: ]*$/;

function emitScalar(v: string | number | boolean | null): string {
  if (v === null) return "null";
  if (typeof v === "boolean" || typeof v === "number") return String(v);
  // Quote anything that could be misread as another scalar type or that
  // contains YAML-significant characters.
  if (
    PLAIN_STRING_RE.test(v) &&
    !/^(true|false|null|~|True|False|Null|NULL)$/.test(v) &&
    !/^-?\d+(\.\d+)?$/.test(v) &&
    !v.includes(": ") &&
    !v.endsWith(":")
  ) {
    return v;
  }
  return `"${v.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;
}

function emitValue(value: YamlValue, indent: number, lines: string[]): void {
  const pad = " ".repeat(indent);
  if (Array.isArray(value)) {
    for (const item of value) {
      if (item !== null && typeof item === "object" && !Array.isArray(item)) {
        const entries = Object.entries(item);
        if (entries.length === 0) {
          lines.push(`${pad}- {}`);
          continue;
        }
        let first = true;
        for (const [k, v] of entries) {
          const prefix = first ? `${pad}- ` : `${pad}  `;
          first = false;
          pushEntry(prefix, k, v, indent + 2, lines);
        }
      } else if (Array.isArray(item)) {
        // Nested bare sequences are not needed by the routing artefacts.
        throw new Error("yaml-lite emitter: nested sequence items unsupported");
      } else {
        lines.push(`${pad}- ${emitScalar(item)}`);
      }
    }
    return;
  }
  if (value !== null && typeof value === "object") {
    for (const [k, v] of Object.entries(value)) {
      pushEntry(pad, k, v, indent, lines);
    }
    return;
  }
  lines.push(`${pad}${emitScalar(value)}`);
}

function pushEntry(
  prefix: string,
  key: string,
  v: YamlValue,
  childIndent: number,
  lines: string[],
): void {
  if (Array.isArray(v)) {
    if (v.length === 0) {
      lines.push(`${prefix}${key}: []`);
    } else {
      lines.push(`${prefix}${key}:`);
      emitValue(v, childIndent + 2, lines);
    }
  } else if (v !== null && typeof v === "object") {
    if (Object.keys(v).length === 0) {
      lines.push(`${prefix}${key}: {}`);
    } else {
      lines.push(`${prefix}${key}:`);
      emitValue(v, childIndent + 2, lines);
    }
  } else {
    lines.push(`${prefix}${key}: ${emitScalar(v)}`);
  }
}

/** Emits a YAML-subset document (round-trips through parseYaml). */
export function emitYaml(value: YamlValue): string {
  const lines: string[] = [];
  emitValue(value, 0, lines);
  return `${lines.join("\n")}\n`;
}
