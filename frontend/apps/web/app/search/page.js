"use client"
import { useMemo, useState } from "react"
import { searchApi } from "@gmp/api"
import { Button, PageHeader, Section } from "@gmp/ui"

const regions = ["All", "North America", "Europe", "Asia Pacific", "Latin America", "Middle East", "Global"]

export default function SearchPage() {
  const [query, setQuery] = useState("")
  const [region, setRegion] = useState("All")
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)

  const stats = useMemo(() => {
    const categories = new Set(results.map(item => item.category))
    return { total: results.length, categories: categories.size }
  }, [results])

  const runSearch = async () => {
    setLoading(true)
    try {
      const data = await searchApi.search(query, region)
      setResults(data || [])
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader title="Search" subtitle="Global catalog discovery across regions and categories." />
      <Section title="Search Controls" subtitle="Filter by region and keyword.">
        <div className="grid grid-3">
          <div className="card">
            <div className="muted">Keyword</div>
            <input
              value={query}
              onChange={e => setQuery(e.target.value)}
              placeholder="Try headphones, storage, accessories..."
              style={{ width: "100%", marginTop: 8, padding: 10, borderRadius: 10, border: "1px solid var(--border)" }}
            />
          </div>
          <div className="card">
            <div className="muted">Region</div>
            <select
              value={region}
              onChange={e => setRegion(e.target.value)}
              style={{ width: "100%", marginTop: 8, padding: 10, borderRadius: 10, border: "1px solid var(--border)" }}
            >
              {regions.map(item => (
                <option key={item} value={item}>{item}</option>
              ))}
            </select>
          </div>
          <div className="card" style={{ display: "flex", alignItems: "flex-end", justifyContent: "flex-end" }}>
            <Button onClick={runSearch}>{loading ? "Searching..." : "Search Catalog"}</Button>
          </div>
        </div>
      </Section>
      <Section title="Search Results" subtitle={`${stats.total} results across ${stats.categories || 0} categories`}>
        {loading ? (
          <div className="empty">Searching catalog...</div>
        ) : results.length ? (
          <table className="table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Category</th>
                <th>Region</th>
                <th>Price</th>
              </tr>
            </thead>
            <tbody>
              {results.map(item => (
                <tr key={item.id}>
                  <td>{item.name}</td>
                  <td>{item.category}</td>
                  <td>{item.region}</td>
                  <td>${item.price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="empty">Run a search to populate results.</div>
        )}
      </Section>
    </div>
  )
}
