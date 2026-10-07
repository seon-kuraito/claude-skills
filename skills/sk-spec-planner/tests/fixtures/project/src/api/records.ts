export type RecordRow = {
  id: string;
  date: string;
  title: string;
  amount: number;
  note: string;
};

export type RecordsPage = {
  rows: RecordRow[];
  total: number;
};

// Fetches one page of records; the server sorts by date, newest first.
export async function fetchRecords(page: number, pageSize = 50): Promise<RecordsPage> {
  const response = await fetch(`/api/records?page=${page}&size=${pageSize}`);
  if (!response.ok) throw new Error(`records: ${response.status}`);
  return response.json();
}
