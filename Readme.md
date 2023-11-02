# smol-string

`smol-string` is a compression library designed for use with browsers' `localStorage` (and `sessionStorage`). It serves as a faster alternative to [`lz-string`](https://github.com/pieroxy/lz-string).

The library is composed of a core algorithm written in [Zig](https://ziglang.org/) compiled to WebAssembly, along with a wrapper provided as a TypeScript library.

Originally, I ensured that it produced valid UTF-16 strings to ensure browser compatibility. However, it now appears that this is not necessary for any of the tested browsers. The default behavior can now result in technically invalid UTF-16 strings.

## Installation

```
npm install -S smol-string
```

## Usage

```ts
import { compress, decompress } from "smol-string";

const input = "Any JS String";

const compressed = compress(input);
const decompressed = decompress(compressed);
```

The default `compress`/`decompress` are optimized for speed and produce bigger output.
`smol-string` also provide a bit packed version which yield compressed sizes similar to `lz-string`, while still being faster:

```ts
import { compressPacked, decompressPacked } from "smol-string-packed";

const compressed = compressPacked(input);
const decompressed = decompressPacked(compressed);
```

Each version is distributed as a separate package to reduce bundle size. You don't want to mix them anyway.

Finally, there's an async version offloading the processing to a webworker. API is identical, expect that each function returns a promise:

```ts
import { compress, decompress } from "smol-string-worker";
// Or
import { compressPacked, decompressPacked } from "smol-string-worker-packed";

const compressed = await compress(input);
const decompressed = await decompress(compressed);
```

## Build

```sh
zig build         # Builds the wasm modules and copies them to `ts-lib/src`.
```

```sh
cd ts-lib
npm ci            # Installs Dependencies.
npm run build     # Builds the Typescript library to `ts-lib/dist`.
```
