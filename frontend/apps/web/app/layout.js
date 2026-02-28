import "./globals.css"
import Link from "next/link"

export const metadata = {
  title: "Global Marketplace Platform",
  description: "Marketplace services dashboard and commerce flows"
}

const navItems = [
  { href: "/", label: "Overview" },
  { href: "/products", label: "Products" },
  { href: "/search", label: "Search" },
  { href: "/cart", label: "Cart" },
  { href: "/checkout", label: "Checkout" },
  { href: "/orders", label: "Orders" },
  { href: "/services", label: "Services" }
]

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <div className="app-shell">
          <aside className="sidebar">
            <div className="sidebar-brand">Global Marketplace</div>
            <nav className="sidebar-nav">
              {navItems.map(item => (
                <Link key={item.href} href={item.href} className="sidebar-link">
                  {item.label}
                </Link>
              ))}
            </nav>
          </aside>
          <main className="main">{children}</main>
        </div>
      </body>
    </html>
  )
}
