# LearnLynk – Technical Assessment

## Stripe Answer

```
Whenever a user decides to pay the application fee, I first create a payment_requests row in the database. This stores the application_id, amount, and marks the status as “pending” so I can track the payment flow. After that, on the server side, I call Stripe’s API to create a Checkout Session, and I pass the payment_request_id and application_id inside the session metadata. The frontend just redirects the user to Stripe Checkout using the returned session ID.

Once the user completes the payment, Stripe sends an event to my webhook. Inside the webhook handler, I verify the signature, then read the metadata from the session to identify which payment_request it belongs to. I mark that row as “paid” and store important details like the payment_intent ID and the Stripe event ID so the webhook is idempotent. After updating the payment record, I also update the related application—usually setting its payment status to “paid” and moving its stage forward. This keeps both the payment table and the application in sync.
```