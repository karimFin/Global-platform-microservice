import { Badge, PageHeader, Section } from "@gmp/ui"

const services = [
  { name: "API Gateway", port: 9000, path: "/health", status: "healthy", description: "Unified entry point for all APIs." },
  { name: "Identity", port: 9001, path: "/health", status: "healthy", description: "Auth, sessions, and access control." },
  { name: "Seller", port: 9002, path: "/health", status: "healthy", description: "Seller onboarding and profiles." },
  { name: "Catalog", port: 9003, path: "/health", status: "healthy", description: "Product catalog and metadata." },
  { name: "Search", port: 9004, path: "/health", status: "healthy", description: "Search indexing and queries." },
  { name: "Pricing", port: 9005, path: "/health", status: "healthy", description: "Pricing rules and promotions." },
  { name: "Inventory", port: 9006, path: "/health", status: "healthy", description: "Inventory and availability." },
  { name: "Cart", port: 9007, path: "/health", status: "healthy", description: "Cart lifecycle and items." },
  { name: "Checkout", port: 9008, path: "/health", status: "healthy", description: "Checkout orchestration." },
  { name: "Payments", port: 9009, path: "/health", status: "healthy", description: "Payments processing." },
  { name: "Orders", port: 9010, path: "/health", status: "healthy", description: "Order creation and tracking." },
  { name: "Fulfillment", port: 9011, path: "/health", status: "healthy", description: "Fulfillment workflows." },
  { name: "Notifications", port: 9012, path: "/health", status: "healthy", description: "Email and event notifications." },
  { name: "Reviews", port: 9013, path: "/health", status: "healthy", description: "Ratings and reviews." },
  { name: "Analytics", port: 9014, path: "/health", status: "healthy", description: "Insights and reporting." }
]

const toneFor = status => {
  if (status === "warning") return "warning"
  if (status === "degraded") return "danger"
  return "success"
}

export default function ServicesPage() {
  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader
        title="Service Directory"
        subtitle="Operational view of every marketplace service in the platform."
      />
      <Section title="Core Services">
        <div className="grid grid-3">
          {services.map(service => (
            <div key={service.name} className="card">
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
                <h3 style={{ margin: 0 }}>{service.name}</h3>
                <Badge tone={toneFor(service.status)}>{service.status}</Badge>
              </div>
              <p className="muted" style={{ marginTop: 8 }}>{service.description}</p>
              <div style={{ marginTop: 12 }}>
                <div className="muted">Port</div>
                <div style={{ fontWeight: 600 }}>localhost:{service.port}</div>
              </div>
              <a
                className="sidebar-link"
                style={{ display: "inline-flex", marginTop: 12, padding: "8px 12px" }}
                href={`http://localhost:${service.port}${service.path}`}
                target="_blank"
                rel="noreferrer"
              >
                View Health
              </a>
            </div>
          ))}
        </div>
      </Section>
    </div>
  )
}
