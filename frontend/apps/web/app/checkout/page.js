"use client"
import { useState } from "react"
import { ordersApi } from "@gmp/api"
import { Badge, Button, PageHeader, Section } from "@gmp/ui"

export default function CheckoutPage() {
  const [status, setStatus] = useState(null)
  const [submitting, setSubmitting] = useState(false)
  const placeOrder = async () => {
    setSubmitting(true)
    try {
      const res = await ordersApi.checkout()
      setStatus(res)
    } finally {
      setSubmitting(false)
    }
  }
  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader title="Checkout" subtitle="Finalize the order and confirm payment flow." />
      <Section title="Order Summary" subtitle="This is a demo checkout flow for service validation.">
        <div className="grid grid-2">
          <div className="card">
            <div className="muted">Status</div>
            <div style={{ marginTop: 8 }}>
              <Badge>{status?.status || "Ready"}</Badge>
            </div>
          </div>
          <div className="card">
            <div className="muted">Payment Provider</div>
            <div style={{ fontSize: 20, fontWeight: 700, marginTop: 8 }}>
              {status?.provider || "MockPay Gateway"}
            </div>
          </div>
        </div>
        <div style={{ marginTop: 16 }}>
          <Button disabled={submitting} onClick={placeOrder}>
            {submitting ? "Processing..." : "Place Order"}
          </Button>
        </div>
        {status && (
          <div className="grid grid-3" style={{ marginTop: 16 }}>
            <div className="card">
              <div className="muted">Order ID</div>
              <div style={{ fontWeight: 700, marginTop: 8 }}>{status.id || "ord-demo"}</div>
            </div>
            <div className="card">
              <div className="muted">Total</div>
              <div style={{ fontWeight: 700, marginTop: 8 }}>
                {status.currency || "USD"} {status.total || "0.00"}
              </div>
            </div>
            <div className="card">
              <div className="muted">Reference</div>
              <div style={{ fontWeight: 700, marginTop: 8 }}>{status.reference || "mp-demo"}</div>
            </div>
          </div>
        )}
      </Section>
      <Section title="Global Checkout Blueprint" subtitle="Compliance, tax, and fulfillment checkpoints.">
        <div className="grid grid-2">
          <div className="card">
            <div className="muted">Tax & Duties</div>
            <p className="muted" style={{ marginTop: 8 }}>VAT/GST, regional duties, and cross-border compliance.</p>
          </div>
          <div className="card">
            <div className="muted">Fraud & Risk</div>
            <p className="muted" style={{ marginTop: 8 }}>Behavioral checks, geo rules, and payment velocity limits.</p>
          </div>
          <div className="card">
            <div className="muted">Fulfillment</div>
            <p className="muted" style={{ marginTop: 8 }}>Carrier selection, SLA-based routing, and shipment tracking.</p>
          </div>
          <div className="card">
            <div className="muted">Customer Comms</div>
            <p className="muted" style={{ marginTop: 8 }}>Email/SMS events, refunds, and post-purchase updates.</p>
          </div>
        </div>
      </Section>
    </div>
  )
}
