"use client"
import { useEffect, useState } from "react"
import { productsApi } from "@gmp/api"
import { PageHeader, Section, ProductCard } from "@gmp/ui"

export default function ProductsPage() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)
  useEffect(() => {
    let active = true
    productsApi.list().then(d => {
      if (active) setItems(d || [])
    }).finally(() => active && setLoading(false))
    return () => { active = false }
  }, [])
  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader
        title="Products"
        subtitle="Browse the catalog and monitor pricing coverage across services."
      />
      <Section title="Catalog">
        {loading ? <div className="empty">Loading catalog data...</div> : (
          items.length ? (
            <div className="grid grid-3">
              {items.map(p => <ProductCard key={p.id} product={p} />)}
            </div>
          ) : (
            <div className="empty">No products available yet.</div>
          )
        )}
      </Section>
      <Section title="Marketplace Coverage" subtitle="Regional readiness and pricing health.">
        <div className="grid grid-3">
          <div className="card">
            <div className="muted">Regions Live</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 8 }}>6</div>
          </div>
          <div className="card">
            <div className="muted">Active Categories</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 8 }}>12</div>
          </div>
          <div className="card">
            <div className="muted">Pricing Health</div>
            <div style={{ fontSize: 22, fontWeight: 700, marginTop: 8 }}>98%</div>
          </div>
        </div>
      </Section>
    </div>
  )
}
