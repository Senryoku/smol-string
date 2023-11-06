import { describe, bench, expect, test, beforeAll } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-packed.js";

const options = { iterations: 20 };

describe.each(TestData)("Compression: $name", ({ name, input }) => {
	bench(
		"compress",
		() => {
			compress(input);
		},
		options
	);
	bench(
		"compressPacked",
		() => {
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
		() => {
			const decompressed = decompress(compressed);
			expect(decompressed).toBe(input);
		},
		options
	);
	bench(
		"decompressPacked",
		() => {
			const decompressed = decompressPacked(compressedPacked);
			expect(decompressed).toBe(input);
		},
		options
	);
});
