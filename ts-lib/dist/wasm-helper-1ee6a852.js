function s(e, n) {
  const t = new TextEncoder().encode(e), a = n.allocUint8(t.length);
  return new Uint8Array(
    n.memory.buffer,
    a,
    t.length
  ).set(t), { ptr: a, length: t.length };
}
function f(e) {
  const n = new Array(e.length);
  for (let t = 0; t < e.length; t++)
    n[t] = String.fromCharCode(e[t]);
  return n.join("");
}
const c = async (e = {}, n) => {
  let t;
  if (n.startsWith("data:")) {
    const a = n.replace(/^data:.*?base64,/, "");
    let r;
    if (typeof Buffer == "function" && typeof Buffer.from == "function")
      r = Buffer.from(a, "base64");
    else if (typeof atob == "function") {
      const i = atob(a);
      r = new Uint8Array(i.length);
      for (let o = 0; o < i.length; o++)
        r[o] = i.charCodeAt(o);
    } else
      throw new Error("Failed to decode base64-encoded data URL, Buffer and atob are not supported");
    t = await WebAssembly.instantiate(r, e);
  } else {
    const a = await fetch(n), r = a.headers.get("Content-Type") || "";
    if ("instantiateStreaming" in WebAssembly && r.startsWith("application/wasm"))
      t = await WebAssembly.instantiateStreaming(a, e);
    else {
      const i = await a.arrayBuffer();
      t = await WebAssembly.instantiate(i, e);
    }
  }
  return t.instance;
};
export {
  f as U,
  s as c,
  c as i
};
