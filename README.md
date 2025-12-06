# LearnLynk – Technical Assessment

## Stripe Answer

# Stripe Checkout — Application Fee Flow

This README describes how the application fee payment system is implemented using **Stripe Checkout**, including how payment requests are created, how Stripe is called.
---

## Overview

The system uses a `payment_requests` table to track all payments. Stripe Checkout handles payment collection, while webhooks confirm success and update both the payment record and the related application.

---

## 🧩 Step-by-Step Flow

### 1. Creating a Payment Request

* When the user decides to pay the application fee, a new row is inserted into **`payment_requests`**.
* The row stores:

  * `application_id`
  * `amount`
  * `status = "pending"`
* This acts as the reference record for the entire payment flow.

### 2. Creating a Stripe Checkout Session

* The backend calls **Stripe's Checkout Session API**.
* Metadata passed inside the session includes:

  * `payment_request_id`
  * `application_id`
* Stripe returns a `session_id`, and the frontend redirects the user to Stripe Checkout.

### 3. Stripe Webhook Handling

* Once the user completes payment, Stripe sends an event to the **webhook endpoint**.
* The webhook:

  * Verifies the Stripe signature.
  * Extracts metadata from the `checkout.session.completed` event.
  * Identifies the related `payment_request` row.

### 4. Updating the Payment Record

* The record in `payment_requests` is updated to **"paid"**.
* Details saved:

  * `payment_intent_id`
  * `stripe_event_id`
* These values ensure **idempotency**, preventing duplicate updates from multiple webhook deliveries.

### 5. Updating the Application

* After payment is confirmed, the associated `application` is updated:

  * Payment status becomes **"paid"**.
  * Application stage moves forward.
* This keeps the payment system and the application workflow perfectly aligned.

---

## ✅ Summary

This flow ensures a secure and consistent Stripe Checkout integration by:

* Tracking each payment request in the database.
* Using Stripe metadata to link sessions with internal records.
* Relying on webhooks for reliable post-payment updates.
* Keeping both payment data and application status synchronized.

This structure makes the payment process clean, traceable, and resilient.
