import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string-worker.js";
import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-worker-packed.js";

describe("compress and decompress", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = await compress(input);
			const decompressed = await decompress(compressed);
			expect(decompressed).toBe(input);
		});
	}
});

describe("compressPacked and decompressPacked", () => {
	for (const { name, input } of TestData) {
		test(name, async () => {
			const compressed = await compressPacked(input);
			const decompressed = await decompressPacked(compressed);
			expect(decompressed).toBe(input);
		});
	}
});
