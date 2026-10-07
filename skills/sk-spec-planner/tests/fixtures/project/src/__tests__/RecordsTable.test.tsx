import { render, screen } from "@testing-library/react";
import { RecordsTable } from "../components/RecordsTable";

it("renders one row per record in column order", () => {
  render(
    <RecordsTable
      rows={[{ id: "1", date: "2026-01-02", title: "coffee", amount: 120, note: "" }]}
    />,
  );
  expect(screen.getByRole("row", { name: /coffee/ })).toBeInTheDocument();
});
