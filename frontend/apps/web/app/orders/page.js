"use client"
import { useState } from "react"
import { ordersApi } from "@gmp/api"
import { Badge, Button, PageHeader, Section } from "@gmp/ui"

const blueprint = [
  { step: "1", title: "Cart Validation", detail: "Inventory lock, price recalculation, and promotions applied." },
  { step: "2", title: "Identity & Risk", detail: "Customer profile, fraud signals, and geo compliance checks." },
  { step: "3", title: "Payment Authorization", detail: "MockPay gateway authorizes with multi-currency support." },
  { step: "4", title: "Order Creation", detail: "Order ID issued, SLA assigned, and fulfillment ticket created." },
  { step: "5", title: "Shipment & Tracking", detail: "Carrier label, tracking events, and delivery ETA updates." },
  { step: "6", title: "Settlement", detail: "Capture funds, reconcile fees, and update analytics." }
]

export default function OrdersPage() {
  const [status, setStatus] = useState(null)
  const [loading, setLoading] = useState(false)

  const simulate = async () => {
    setLoading(true)
    try {
      const res = await ordersApi.checkout()
      setStatus(res)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader
        title="Order Blueprint"
        subtitle="End-to-end order lifecycle for a global marketplace."
        actions={<Button onClick={simulate}>{loading ? "Simulating..." : "Run Mock Order"}</Button>}
      />
      <Section title="Process Flow" subtitle="Operational steps and service touchpoints.">
        <div className="grid grid-2">
          {blueprint.map(item => (
            <div key={item.step} className="card">
              <div className="muted">Step {item.step}</div>
              <h3 style={{ margin: "8px 0" }}>{item.title}</h3>
              <p className="muted">{item.detail}</p>
            </div>
          ))}
        </div>
      </Section>
      <Section title="Mock Order Output" subtitle="Simulated payment and fulfillment details.">
        {status ? (
          <div className="grid grid-3">
            <div className="card">
              <div className="muted">Order ID</div>
              <div style={{ fontWeight: 700, marginTop: 8 }}>{status.id || "ord-demo"}</div>
            </div>
            <div className="card">
              <div className="muted">Payment Status</div>
              <div style={{ marginTop: 8 }}>
                <Badge>{status.status || "paid"}</Badge>
              </div>
            </div>
            <div className="card">
              <div className="muted">Provider</div>
              <div style={{ fontWeight: 700, marginTop: 8 }}>{status.provider || "MockPay Gateway"}</div>
            </div>
          </div>
        ) : (
          <div className="empty">Run a mock order to see gateway output.</div>
        )}
      </Section>
    </div>
  )
}
