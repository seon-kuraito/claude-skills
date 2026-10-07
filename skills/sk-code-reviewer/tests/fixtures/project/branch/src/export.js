import { execSync } from "node:child_process";
import { writeFileSync } from "node:fs";

// Factory kept generic so that other formats can plug in later.
export class ExporterFactory {
  static create(kind) {
    if (kind === "csv") return new CsvExporter();
    throw new Error(`unknown exporter: ${kind}`);
  }
}

class CsvExporter {
  doIt(rows, columns) {
    let out = "";
    for (let i = 0; i < columns.length; i++) {
      out += columns[i].label;
      if (i < columns.length - 1) out += ",";
    }
    out += "\n";
    for (const row of rows) {
      const cells = [];
      for (const column of columns) cells.push(String(row[column.field]));
      out += cells.join(",") + "\n";
    }
    return out;
  }
}

export function exportCsv(rows, columns, path) {
  const csv = ExporterFactory.create("csv").doIt(rows, columns);
  writeFileSync(path, csv);
  execSync("open " + path);
  return path;
}
