function o(n, e) {
  const t = new TextEncoder().encode(n), a = e.allocUint8(t.length);
  return new Uint8Array(
    e.memory.buffer,
    a,
    t.length
  ).set(t), { ptr: a, length: t.length };
}
function f(n) {
  const e = new Array(n.length);
  for (let t = 0; t < n.length; t++)
    e[t] = String.fromCharCode(n[t]);
  return e.join("");
}
function c(n, e) {
  const t = new Uint32Array(
    n.buffer.slice(e, e + 8)
  ), a = t.at(0), r = t.at(1);
  return {
    start: e - a,
    end: e,
    capacity: r
  };
}
const l = async (n = {}, e) => {
  let t;
  if (e.startsWith("data:")) {
    const a = e.replace(/^data:.*?base64,/, "");
    let r;
    if (typeof Buffer == "function" && typeof Buffer.from == "function")
      r = Buffer.from(a, "base64");
    else if (typeof atob == "function") {
      const s = atob(a);
      r = new Uint8Array(s.length);
      for (let i = 0; i < s.length; i++)
        r[i] = s.charCodeAt(i);
    } else
      throw new Error("Failed to decode base64-encoded data URL, Buffer and atob are not supported");
    t = await WebAssembly.instantiate(r, n);
  } else {
    const a = await fetch(e), r = a.headers.get("Content-Type") || "";
    if ("instantiateStreaming" in WebAssembly && r.startsWith("application/wasm"))
      t = await WebAssembly.instantiateStreaming(a, n);
    else {
      const s = await a.arrayBuffer();
      t = await WebAssembly.instantiate(s, n);
    }
  }
  return t.instance;
};
export {
  f as U,
  o as c,
  c as e,
  l as i
};
