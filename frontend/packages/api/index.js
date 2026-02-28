const envBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:9000"
const BASE_URL = typeof window !== "undefined" && envBaseUrl.includes("host.docker.internal")
  ? envBaseUrl.replace("host.docker.internal", "localhost")
  : envBaseUrl

async function req(path, opts) {
  const res = await fetch(BASE_URL + path, { headers: { "Content-Type": "application/json" }, ...opts })
  if (!res.ok) return null
  try { return await res.json() } catch { return null }
}

export const productsApi = {
  async list() {
    return req("/catalog/products")
  },
  async get(id) {
    return req(`/catalog/products/${id}`)
  }
}

export const cartApi = {
  async get() {
    return req("/cart")
  },
  async add(productId, quantity) {
    return req("/cart/items", { method: "POST", body: JSON.stringify({ productId, quantity }) })
  }
}

export const ordersApi = {
  async checkout() {
    return req("/checkout", { method: "POST" })
  },
  async status(id) {
    return req(`/orders/${id}`)
  }
}

export const searchApi = {
  async search(query = "", region = "All") {
    return req(`/search?q=${encodeURIComponent(query)}&region=${encodeURIComponent(region)}`)
  }
}
