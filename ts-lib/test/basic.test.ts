import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";
import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-packed.js";

describe("compress and decompress", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = compress(input);
			const decompressed = decompress(compressed);
			expect(decompressed).toBe(input);
		});
	}
});

describe("compressPacked and decompressPacked", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = compressPacked(input);
			const decompressed = decompressPacked(compressed);
			expect(decompressed).toBe(input);
		});
	}
});
