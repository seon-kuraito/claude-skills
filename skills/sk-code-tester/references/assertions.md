# Assertions

An assertion is what makes a test fail for the right reason. Implicit assertions are the ones you do not write: they come with the actions and the comparisons the test already makes.

## What a test already asserts

```ts
import { sum } from "./sum";

it("adds two numbers", () => {
  expect(sum(2, 5)).toBe(7);
});
```

This one line also asserts that the module exists, that `sum` is a function, and that it runs without throwing. None of that needs its own `expect`.

```ts
render(<Checkout />);
await user.click(screen.getByRole("button", { name: "Pay" }));
```

`render` asserts that the component renders; `getByRole` asserts that the button is in the document. An existence check between the two lines repeats what the click proves.

## Delete what is implied

```diff
-expect(items).toHaveLength(3);
 expect(items).toEqual(["a", "b", "c"]);
```

The equality covers the length, and on failure it prints the diff of the whole array, which a length mismatch never would.

```diff
 render(<Profile />);
-expect(screen.getByTestId("container")).toBeInTheDocument();
-expect(screen.getByRole("textbox", { name: "Email" })).toBeInTheDocument();
 await user.type(screen.getByRole("textbox", { name: "Email" }), "a@example.com");
-expect(screen.getByRole("textbox", { name: "Email" })).toHaveValue("a@example.com");
 await user.click(screen.getByRole("button", { name: "Save" }));
 expect(await screen.findByText("Saved")).toBeVisible();
```

The actions that follow prove each deleted line.

## Keep what states the intention

The assertion left behind must relate to what the test is for. A test named "saves the email" ends on the saved state, not on the textbox holding a value.

## Setup checks are not assertions

```ts
const fixture = await loadFixture("orders.json");
if (!fixture) throw new Error("fixture orders.json is missing");
```

A failure here is a broken test setup, not a broken system. A plain throw says so; an `expect` would make it read like a failed behaviour.
