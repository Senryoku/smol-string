# smol-string

`smol-string` is a compression library designed to be used with browsers' `localStorage` (and `sessionStorage`). It is intended to be a faster alternative to [`lz-string`](https://github.com/pieroxy/lz-string).

It is composed of the core algorithm written in [Zig](https://ziglang.org/) compiled to Wasm and a wrapper in the form of a Typescript library.

I originally made sure it produced valid UTF-16 strings to ensure browser compatibility, however this doesn't seem to be necessary for any of the tested browsers. The default can now produce technically invalid UTF-16 strings. I might add back a way to limit it to valid UTF-16 if there's a need.

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

## Todos

-   Integrate the run length at the start of the output stream instead of using a end sentinel?

## Build

```sh
zig build         # Builds the wasm modules and copies them to `ts-lib/src`.
```

```sh
cd ts-lib
npm ci            # Installs Dependencies.
npm run build     # Builds the Typescript library to `ts-lib/dist`.
```
