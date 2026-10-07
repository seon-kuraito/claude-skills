export const columns = [
  { field: "date", label: "日期" },
  { field: "title", label: "標題" },
  { field: "amount", label: "金額" },
];

const sample = [
  { date: "2026-01-02", title: "coffee", amount: 120 },
  { date: "2026-01-03", title: "lunch", amount: 250 },
];

// Returns every record, newest first.
export function listRecords() {
  return [...sample].sort((a, b) => (a.date < b.date ? 1 : -1));
}
