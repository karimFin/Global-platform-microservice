import React from "react"

export function PageHeader({ title, subtitle, actions }) {
  return (
    <div className="page-header">
      <div>
        <h1 className="page-title">{title}</h1>
        {subtitle && <p className="page-subtitle">{subtitle}</p>}
      </div>
      {actions && <div>{actions}</div>}
    </div>
  )
}

export function Section({ title, subtitle, children }) {
  return (
    <section className="card">
      <h2 className="section-title">{title}</h2>
      {subtitle && <p className="section-subtitle">{subtitle}</p>}
      {children}
    </section>
  )
}

export function StatCard({ label, value, hint }) {
  return (
    <div className="card">
      <div className="muted">{label}</div>
      <div style={{ fontSize: 24, fontWeight: 700, marginTop: 8 }}>{value}</div>
      {hint && <div className="muted" style={{ marginTop: 6 }}>{hint}</div>}
    </div>
  )
}

export function Badge({ children, tone = "success" }) {
  const toneClass = tone === "warning" ? "badge-warning" : tone === "danger" ? "badge-danger" : "badge-success"
  return <span className={`badge ${toneClass}`}>{children}</span>
}

export function Button({ children, variant = "primary", ...props }) {
  const className = variant === "ghost" ? "button button-ghost" : "button button-primary"
  return (
    <button className={className} {...props}>
      {children}
    </button>
  )
}

export function ProductCard({ product }) {
  return (
    <div className="card">
      <h3 style={{ marginTop: 0 }}>{product.name}</h3>
      <div className="muted">{product.category || "General"}</div>
      <div style={{ fontSize: 20, fontWeight: 700, margin: "12px 0" }}>
        ${product.price?.toFixed ? product.price.toFixed(2) : product.price}
      </div>
      <Button variant="ghost">Add to cart</Button>
    </div>
  )
}
