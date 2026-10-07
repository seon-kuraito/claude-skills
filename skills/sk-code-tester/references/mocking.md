# When to mock

Mock at **system boundaries** only:

- External APIs (payment, email, and the like)
- Databases (sometimes; prefer a test database)
- Time and randomness
- The file system (sometimes)

Do not mock:

- Your own classes and modules
- Internal collaborators
- Anything you control

## Designing for mockability

At system boundaries, design interfaces that are easy to mock.

**1. Use dependency injection.** Pass external dependencies in rather than creating them internally:

```ts
// easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Prefer SDK-style interfaces over generic fetchers.** Create one function per external operation instead of one generic function with conditional logic:

```ts
// GOOD: each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch("/orders", { method: "POST", body: data }),
};

// BAD: mocking needs conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

The SDK approach means each mock returns one specific shape, no conditional logic in the test setup, and a test that shows which endpoints it exercises.
