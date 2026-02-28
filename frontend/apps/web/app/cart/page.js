"use client"
import { useEffect, useState } from "react"
import { cartApi } from "@gmp/api"
import { PageHeader, Section } from "@gmp/ui"

export default function CartPage() {
  const [cart, setCart] = useState(null)
  useEffect(() => {
    cartApi.get().then(data => setCart(data || { items: [] }))
  }, [])
  return (
    <div className="grid" style={{ gap: 24 }}>
      <PageHeader title="Cart" subtitle="Review selected items and prepare for checkout." />
      <Section title="Current Items">
        {!cart ? (
          <div className="empty">Loading cart...</div>
        ) : cart.items.length ? (
          <table className="table">
            <thead>
              <tr>
                <th>Product</th>
                <th>Quantity</th>
              </tr>
            </thead>
            <tbody>
              {cart.items.map(item => (
                <tr key={item.productId}>
                  <td>{item.name}</td>
                  <td>{item.quantity}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <div className="empty">Your cart is empty.</div>
        )}
      </Section>
    </div>
  )
}
