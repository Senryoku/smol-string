import { describe, bench, expect, test, beforeAll } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-packed.js";

const options = { iterations: 5 };

describe.each(TestData)("Compression: $name", ({ name, input }) => {
	bench(
		"compress",
		async () => {
			compress(input);
		},
		options
	);
	bench(
		"compressPacked",
		async () => {
			compressPacked(input);
		},
		options
	);
});

describe.each(TestData)("Decompression: $name", ({ name, input }) => {
	let compressed = compress(input);
	let compressedPacked = compressPacked(input);

	bench(
		"decompress",
		async () => {
			const decompressed = decompress(compressed);
			expect(decompressed).toBe(input);
		},
		options
	);
	bench(
		"decompressPacked",
		async () => {
			const decompressed = decompressPacked(compressedPacked);
			expect(decompressed).toBe(input);
		},
		options
	);
});
