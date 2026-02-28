import Link from "next/link"
import { Button, PageHeader, Section, StatCard } from "@gmp/ui"

const quickLinks = [
  { href: "/products", label: "Browse Products", detail: "Explore the catalog" },
  { href: "/cart", label: "Review Cart", detail: "Items ready to purchase" },
  { href: "/checkout", label: "Checkout", detail: "Place and track orders" },
  { href: "/services", label: "Service Status", detail: "Infra health view" }
]

export default function Page() {
  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader
        title="Global Marketplace Platform"
        subtitle="Unified commerce experience across catalog, cart, and fulfillment services."
        actions={<Button>New Order</Button>}
      />
      <div className="grid grid-3">
        <StatCard label="Active Services" value="15" hint="Dev environment" />
        <StatCard label="Deploy Target" value="Kubernetes" hint="Local compose ready" />
        <StatCard label="API Gateway" value="9000" hint="Running on localhost" />
      </div>
      <Section title="Quick Actions" subtitle="Jump into the most common workflows.">
        <div className="grid grid-2">
          {quickLinks.map(link => (
            <Link key={link.href} href={link.href} className="card">
              <h3 style={{ marginTop: 0 }}>{link.label}</h3>
              <p className="muted">{link.detail}</p>
            </Link>
          ))}
        </div>
      </Section>
      <Section title="Environment Highlights" subtitle="Key services and integrations in this stack.">
        <div className="grid grid-2">
          <div className="card">
            <h3 style={{ marginTop: 0 }}>Catalog + Inventory</h3>
            <p className="muted">Keep product availability and pricing aligned for every region.</p>
          </div>
          <div className="card">
            <h3 style={{ marginTop: 0 }}>Orders + Payments</h3>
            <p className="muted">End-to-end checkout flow with clean service boundaries.</p>
          </div>
        </div>
      </Section>
    </div>
  )
}
