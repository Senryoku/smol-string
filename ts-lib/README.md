# smol-string

`smol-string` is a compression library designed for use with browsers' `localStorage` (and `sessionStorage`). It serves as a faster alternative to [`lz-string`](https://github.com/pieroxy/lz-string).

For more information, check the [GitHub Repository](https://github.com/Senryoku/smol-string).

## Installation

```
npm install -S smol-string
```

## Basic Usage

```ts
import { compress, decompress } from "smol-string";

const input = "Any JS String";

const compressed = compress(input);
const decompressed = decompress(compressed);
```
