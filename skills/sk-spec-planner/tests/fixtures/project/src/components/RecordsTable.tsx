import type { RecordRow } from "../api/records";

export const columns = [
  { field: "date", label: "日期" },
  { field: "title", label: "標題" },
  { field: "amount", label: "金額" },
  { field: "note", label: "備註" },
] as const;

export function RecordsTable({ rows }: { rows: RecordRow[] }) {
  return (
    <table>
      <thead>
        <tr>
          {columns.map((column) => (
            <th key={column.field}>{column.label}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr key={row.id}>
            {columns.map((column) => (
              <td key={column.field}>{String(row[column.field])}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
